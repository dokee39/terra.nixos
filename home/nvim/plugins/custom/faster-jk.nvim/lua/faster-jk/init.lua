local M = {}

local uv = vim.uv
local ns = vim.api.nvim_create_namespace("faster-jk")

local defaults = {
  threshold = 120, -- ms
  max_step = 6,
}

M.opts = vim.deepcopy(defaults)

local state = {
  last_key = nil,
  last_mode = nil,
  last_time = 0,
  streak = 0,
}

local RAMP_EVERY = 4

local function reset()
  state.last_key = nil
  state.last_mode = nil
  state.last_time = 0
  state.streak = 0
end

local function get_step(streak)
  return math.min(1 + math.floor(streak / RAMP_EVERY), M.opts.max_step)
end

local function threshold_ns()
  return M.opts.threshold * 1000000
end

local function is_motion_mode(mode)
  return mode == "n" or mode == "v" or mode == "V" or mode == "\22"
end

vim.on_key(function(_, typed)
  if not typed or typed == "" then
    return
  end

  if not is_motion_mode(vim.api.nvim_get_mode().mode)
    or (typed ~= "j" and typed ~= "k")
  then
    reset()
  end
end, ns)

function M.setup(opts)
  opts = opts or {}

  vim.validate({
    threshold = { opts.threshold, "number", true },
    max_step = { opts.max_step, "number", true },
  })

  M.opts = vim.tbl_extend("force", vim.deepcopy(defaults), opts)
end

function M.expr(key)
  if key ~= "j" and key ~= "k" then
    return key
  end

  local mode = vim.api.nvim_get_mode().mode

  if vim.v.count > 0 then
    reset()
    return key
  end

  local now = uv.hrtime()

  if state.last_key == key
    and state.last_mode == mode
    and (now - state.last_time) <= threshold_ns()
  then
    state.streak = state.streak + 1
  else
    state.streak = 0
  end

  state.last_key = key
  state.last_mode = mode
  state.last_time = now

  local step = get_step(state.streak)
  return step == 1 and key or (tostring(step) .. key)
end

return M
