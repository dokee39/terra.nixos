local M = {}

local ns = vim.api.nvim_create_namespace("repeatmove")

local state = {
  move_pairs = {},
  recent = "",
  max_len = 0,
  active = nil,
  repeat_buf = nil,
  repeat_maps = {},
}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function endswith(s, suffix)
  return #suffix <= #s and s:sub(-#suffix) == suffix
end

local function count_prefix()
  return vim.v.count > 0 and tostring(vim.v.count) or ""
end

local function replay(raw_keys)
  vim.api.nvim_feedkeys(raw_keys, "m", false)
  vim.api.nvim_feedkeys("", "x", false)
end

local function uninstall_repeat_maps()
  if state.repeat_buf then
    for _, lhs in ipairs(state.repeat_maps) do
      pcall(vim.keymap.del, "n", lhs, { buffer = state.repeat_buf })
    end
  end

  state.repeat_maps = {}
  state.repeat_buf = nil
end

local function clear_active()
  state.active = nil
  uninstall_repeat_maps()
end

local function normalize_pair_list(value, name)
  assert(type(value) == "table", "repeatmove: " .. name .. " is required")

  if type(value[1]) == "string" then
    value = { value }
  end

  local result = {}

  for _, pair in ipairs(value) do
    assert(type(pair) == "table", "repeatmove: each " .. name .. " item must be a table")
    assert(#pair == 2, "repeatmove: each " .. name .. " item must contain exactly 2 keys")
    assert(type(pair[1]) == "string" and type(pair[2]) == "string", "repeatmove: each " .. name .. " item must contain strings")
    result[#result + 1] = { pair[1], pair[2] }
  end

  assert(#result > 0, "repeatmove: " .. name .. " must not be empty")
  return result
end

local function normalize_group(group)
  local move_pairs = normalize_pair_list(group.move, "move")

  local repeat_value = group.repeat_keys
  local repeat_name = "repeat_keys"

  if repeat_value == nil then
    repeat_value = group["repeat"]
    repeat_name = "repeat"
  end

  assert(repeat_value ~= nil, "repeatmove: repeat_keys or repeat is required")

  local repeat_pairs = normalize_pair_list(repeat_value, repeat_name)
  local normalized_repeat_pairs = {}

  for _, pair in ipairs(repeat_pairs) do
    normalized_repeat_pairs[#normalized_repeat_pairs + 1] = {
      pair[1],
      pair[2],
      termcodes(pair[1]),
      termcodes(pair[2]),
    }
  end

  local result = {}

  for _, pair in ipairs(move_pairs) do
    result[#result + 1] = {
      move_raw = { termcodes(pair[1]), termcodes(pair[2]) },
      repeat_pairs = normalized_repeat_pairs,
    }
  end

  return result
end

local function find_best_move_match()
  local best_pair = nil
  local best_len = 0

  for _, pair in ipairs(state.move_pairs) do
    for i = 1, 2 do
      local raw = pair.move_raw[i]
      if endswith(state.recent, raw) and #raw > best_len then
        best_pair = pair
        best_len = #raw
      end
    end
  end

  return best_pair
end

local function is_count_digit_typed(typed)
  if not typed:match("^%d$") then
    return false
  end

  if typed ~= "0" then
    return true
  end

  return vim.v.count > 0
end

local function install_repeat_maps_for_active_buffer(pair, bufnr)
  uninstall_repeat_maps()

  state.repeat_buf = bufnr

  local seen = {}

  for _, repeat_pair in ipairs(pair.repeat_pairs) do
    for side = 1, 2 do
      local lhs = repeat_pair[side]
      local lhs_raw = repeat_pair[side + 2]

      if not seen[lhs_raw] then
        seen[lhs_raw] = true
        state.repeat_maps[#state.repeat_maps + 1] = lhs

        vim.keymap.set("n", lhs, function()
          local active = state.active
          if active ~= pair then
            return
          end

          if vim.api.nvim_get_mode().mode ~= "n" then
            return
          end

          if state.repeat_buf ~= vim.api.nvim_get_current_buf() then
            return
          end

          local prefix = count_prefix()

          for _, rp in ipairs(active.repeat_pairs) do
            if lhs_raw == rp[3] then
              replay(prefix .. active.move_raw[1])
              return
            end

            if lhs_raw == rp[4] then
              replay(prefix .. active.move_raw[2])
              return
            end
          end
        end, {
          buffer = bufnr,
          nowait = true,
          silent = true,
          desc = "repeatmove-active",
        })
      end
    end
  end
end

local function set_active(pair, bufnr)
  if state.active == pair and state.repeat_buf == bufnr then
    return
  end

  state.active = pair
  install_repeat_maps_for_active_buffer(pair, bufnr)
end

local function clear_active_if_needed(typed)
  local active = state.active
  if not active then
    return
  end

  if vim.api.nvim_get_mode().mode ~= "n" then
    clear_active()
    return
  end

  if state.repeat_buf ~= vim.api.nvim_get_current_buf() then
    clear_active()
    return
  end

  if is_count_digit_typed(typed) then
    return
  end

  for _, repeat_pair in ipairs(active.repeat_pairs) do
    if endswith(state.recent, repeat_pair[3]) or endswith(state.recent, repeat_pair[4]) then
      return
    end
  end

  clear_active()
end

function M.clear()
  clear_active()
end

function M.setup(opts)
  opts = opts or {}

  pcall(vim.on_key, nil, ns)
  clear_active()

  state.move_pairs = {}
  state.recent = ""
  state.max_len = 0

  local groups_input
  if opts.move then
    groups_input = { opts }
  else
    groups_input = opts.groups or {}
  end

  assert(#groups_input > 0, "repeatmove: no groups configured")

  for _, group in ipairs(groups_input) do
    local pairs = normalize_group(group)

    for _, pair in ipairs(pairs) do
      state.move_pairs[#state.move_pairs + 1] = pair
      state.max_len = math.max(state.max_len, #pair.move_raw[1], #pair.move_raw[2])

      for _, repeat_pair in ipairs(pair.repeat_pairs) do
        state.max_len = math.max(state.max_len, #repeat_pair[3], #repeat_pair[4])
      end
    end
  end

  vim.on_key(function(_, typed)
    if not typed or typed == "" then
      return
    end

    if vim.api.nvim_get_mode().mode ~= "n" then
      clear_active()
      return
    end

    state.recent = state.recent .. typed
    if #state.recent > state.max_len then
      state.recent = state.recent:sub(-state.max_len)
    end

    local matched = find_best_move_match()
    if matched then
      set_active(matched, vim.api.nvim_get_current_buf())
      return
    end

    clear_active_if_needed(typed)
  end, ns)
end

return M
