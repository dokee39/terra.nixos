--- @since 25.2.13

local pathfmt = require("ranger-like.pathfmt")

local home = ya.target_family() == "unix" and os.getenv("HOME") or nil

local get_entry = ya.sync(function(state, url)
  state.header_entries = state.header_entries or {}
  return state.header_entries[url]
end)

local begin_load = ya.sync(function(state, url)
  state.header_loading = state.header_loading or {}

  if state.header_loading[url] then
    return false
  end

  state.header_loading[url] = true
  return true
end)

local finish_load = ya.sync(function(state, url, segments)
  state.header_entries = state.header_entries or {}
  state.header_loading = state.header_loading or {}

  state.header_loading[url] = nil
  state.header_entries[url] = segments

  ui.render()
end)

local fail_load = ya.sync(function(state, url)
  state.header_loading = state.header_loading or {}
  state.header_loading[url] = nil
end)

local function copy_parts(parts)
  local out = {}

  for i, part in ipairs(parts) do
    out[i] = {
      text = part.text,
      dim = part.dim,
    }
  end

  return out
end

local function copy_segment(segment)
  return {
    parts = copy_parts(segment.parts),
    is_link = segment.is_link,
  }
end

local function append_range(out, segments, from_i, to_i)
  for i = from_i, to_i do
    out[#out + 1] = copy_segment(segments[i])
  end
end

local function width_of_text(text)
  if not text or text == "" then
    return 0
  end

  return ui.Line(text):width()
end

local function text_of_segments(segments)
  local parts = {}

  for i, segment in ipairs(segments) do
    parts[i] = pathfmt.text(segment.parts)
  end

  return table.concat(parts)
end

local function starts_with_path(path, prefix)
  if not prefix or prefix == "" then
    return false
  end

  if path == prefix then
    return true
  end

  if #path <= #prefix then
    return false
  end

  return path:sub(1, #prefix) == prefix and path:sub(#prefix + 1, #prefix + 1) == "/"
end

local function split_path(path)
  local parts = {}

  for part in path:gmatch("[^/]+") do
    parts[#parts + 1] = part
  end

  return parts
end

local function segment_link(url, resolve_link)
  if not resolve_link or not url then
    return false
  end

  local cha = fs.cha(Url(url), false)
  return cha and cha.is_link or false
end

local function push_segment(segments, parts, url, resolve_link)
  segments[#segments + 1] = {
    parts = parts,
    is_link = segment_link(url, resolve_link),
  }
end

local function build_segments(cwd, resolve_link)
  local cwd_str = type(cwd) == "string" and cwd or tostring(cwd)
  local segments = {}
  local current = ""
  local rest = cwd_str

  if home and starts_with_path(cwd_str, home) then
    push_segment(segments, { { text = "~/" } }, home, resolve_link)

    current = home
    rest = cwd_str:sub(#home + 1)
    if rest:sub(1, 1) == "/" then
      rest = rest:sub(2)
    end
  else
    push_segment(segments, { { text = "/" } }, nil, resolve_link)
    rest = cwd_str == "/" and "" or cwd_str:sub(2)
  end

  local parts = split_path(rest)
  local start = 1

  if current == "" and parts[1] == "nix" and parts[2] == "store" and parts[3] then
    current = "/nix/store/" .. parts[3]
    push_segment(segments, pathfmt.parts(parts[3], true, "/"), current, resolve_link)
    start = 4
  end

  for i = start, #parts do
    current = (current == "" or current == "/") and ("/" .. parts[i]) or (current .. "/" .. parts[i])
    push_segment(segments, pathfmt.parts(parts[i], false, "/"), current, resolve_link)
  end

  return segments
end

local function ellipsis_segment()
  return {
    parts = {
      { text = "…/" },
    },
    is_link = false,
  }
end

local function full_path(segments)
  local out = {}
  append_range(out, segments, 1, #segments)
  return out
end

local function compact_path(segments, tail_count, keep_head)
  local limit = keep_head and (tail_count + 1) or tail_count
  if #segments <= limit then
    return full_path(segments)
  end

  local out = {}

  if keep_head then
    out[#out + 1] = copy_segment(segments[1])
  end

  out[#out + 1] = ellipsis_segment()
  append_range(out, segments, #segments - tail_count + 1, #segments)

  return out
end

local function last_path(segments, max)
  if max <= 0 or #segments == 0 then
    return {}
  end

  local last = segments[#segments]
  local last_text = pathfmt.text(last.parts)

  if #segments == 1 then
    return {
      {
        parts = {
          {
            text = ui.truncate(last_text, { max = max, rtl = true }),
          },
        },
        is_link = last.is_link,
      },
    }
  end

  local ellipsis = "…/"
  local ellipsis_width = width_of_text(ellipsis)

  if max <= ellipsis_width then
    return { ellipsis_segment() }
  end

  return {
    ellipsis_segment(),
    {
      parts = {
        {
          text = ui.truncate(last_text, { max = max - ellipsis_width, rtl = true }),
        },
      },
      is_link = last.is_link,
    },
  }
end

local function pick_path_segments(segments, max)
  if max <= 0 or #segments == 0 then
    return {}, 0
  end

  local builders = {
    function()
      return full_path(segments)
    end,
    function()
      return compact_path(segments, 2, true)
    end,
    function()
      return compact_path(segments, 1, true)
    end,
    function()
      return compact_path(segments, 2, false)
    end,
    function()
      return compact_path(segments, 1, false)
    end,
    function()
      return last_path(segments, max)
    end,
  }

  for _, build in ipairs(builders) do
    local candidate = build()
    local width = width_of_text(text_of_segments(candidate))
    if width <= max then
      return candidate, width
    end
  end

  return {}, 0
end

local function identity_info()
  if ya.target_family() ~= "unix" then
    return nil
  end

  local user = ya.user_name()
  local host = ya.host_name()
  if not user or not host then
    return nil
  end

  return {
    text = user .. "@" .. host,
    color = user == "root" and "red" or "green",
  }
end

local function hovered_parts(current)
  local hovered = current.hovered
  if not hovered or not hovered.url or not hovered.url.name then
    return nil
  end

  return pathfmt.parts(tostring(hovered.url.name), tostring(current.cwd) == "/nix/store", "")
end

local function filter_text(current)
  local files = current.files
  local filter = files and files.filter
  if not filter then
    return nil
  end

  return string.format(" (filter: %s)", filter)
end

local function append_parts(line, parts, color)
  for _, part in ipairs(parts) do
    local span = ui.Span(part.text):fg(color)
    if part.dim then
      span = span:dim()
    end
    line[#line + 1] = span
  end
end

local function append_path(line, segments)
  for _, segment in ipairs(segments) do
    append_parts(line, segment.parts, segment.is_link and "cyan" or "blue")
  end
end

local function schedule_load(url)
  if not begin_load(url) then
    return
  end

  ya.async(function()
    local ok, result = pcall(build_segments, url, true)
    if ok then
      finish_load(url, result)
    else
      fail_load(url)
    end
  end)
end

local setup_done = false
local M = {}

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  Header:children_remove(1, Header.LEFT)

  Header:children_add(function(self)
    local current = self._current
    local cwd = current.cwd
    if not cwd then
      return ""
    end

    if not cwd.spec.is_regular or cwd.spec.is_search then
      return self:cwd()
    end

    local max = self._area.w - self._right_width
    if max <= 0 then
      return ""
    end

    local identity = identity_info()
    local filter = filter_text(current)
    local hovered = hovered_parts(current)

    local prefix_width = identity and width_of_text(identity.text .. " ") or 0
    local suffix_width = width_of_text(filter or "")
    local budget = max - prefix_width - suffix_width

    local line = {}

    if identity then
      line[#line + 1] = ui.Span(identity.text):fg(identity.color):bold()
      line[#line + 1] = " "
    end

    if budget > 0 then
      local url = tostring(cwd)
      local segments = get_entry(url)

      if not segments then
        schedule_load(url)
        segments = build_segments(cwd, false)
      end

      local hovered_width = hovered and width_of_text(pathfmt.text(hovered)) or 0
      local path_budget = budget - hovered_width
      if path_budget < 0 then
        path_budget = 0
      end

      local path = {}
      if path_budget > 0 then
        path = pick_path_segments(segments, path_budget)
        append_path(line, path)
      end

      if hovered and hovered_width <= budget then
        append_parts(line, hovered, "white")
      end
    end

    if filter then
      line[#line + 1] = ui.Span(filter):fg("magenta")
    end

    return ui.Line(line)
  end, 1000, Header.LEFT)

  local function refresh()
    local cwd = cx.active.current.cwd
    if not cwd or not cwd.spec.is_regular or cwd.spec.is_search then
      return
    end

    schedule_load(tostring(cwd))
  end

  ps.sub("cd", refresh)

  ps.sub("load", function(args)
    local cwd = cx.active.current.cwd
    if not cwd or not cwd.spec.is_regular or cwd.spec.is_search then
      return
    end

    if tostring(args.url) ~= tostring(cwd) then
      return
    end

    refresh()
  end)
end

return M
