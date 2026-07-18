--- @since 25.2.13

local refresh_symlink_after_seconds = 1

local function signature(cha)
  return table.concat({
    tostring(cha.is_dir),
    tostring(cha.is_link),
    tostring(cha.is_orphan),
    tostring(cha.is_fifo),
    tostring(cha.is_sock),
    tostring(cha.is_char),
    tostring(cha.is_block),
    tostring(cha.len or ""),
    tostring(cha.mtime or ""),
  }, "|")
end

local get_entry = ya.sync(function(state, url)
  state.linemode_entries = state.linemode_entries or {}
  return state.linemode_entries[url]
end)

-- Keep older async results from overwriting newer loads or prefetches.
local begin_load = ya.sync(function(state, url, sig)
  state.linemode_loading = state.linemode_loading or {}
  state.linemode_latest = state.linemode_latest or {}

  local loading = state.linemode_loading[url]
  if loading and loading.sig == sig then
    return false
  end

  state.linemode_revision = (state.linemode_revision or 0) + 1
  local revision = state.linemode_revision
  state.linemode_loading[url] = { sig = sig, revision = revision }
  state.linemode_latest[url] = revision
  return true
end)

local finish_load = ya.sync(function(state, url, sig, text)
  state.linemode_entries = state.linemode_entries or {}
  state.linemode_loading = state.linemode_loading or {}
  state.linemode_latest = state.linemode_latest or {}

  local loading = state.linemode_loading[url]
  if not loading or loading.sig ~= sig then
    return
  end

  state.linemode_loading[url] = nil
  if state.linemode_latest[url] ~= loading.revision then
    return
  end

  state.linemode_latest[url] = nil
  state.linemode_entries[url] = {
    sig = sig,
    text = text,
    refreshed_at = ya.time(),
  }

  ui.render()
end)

local fail_load = ya.sync(function(state, url, sig)
  state.linemode_loading = state.linemode_loading or {}
  state.linemode_latest = state.linemode_latest or {}

  local loading = state.linemode_loading[url]
  if not loading or loading.sig ~= sig then
    return
  end

  state.linemode_loading[url] = nil
  if state.linemode_latest[url] == loading.revision then
    state.linemode_latest[url] = nil
  end
end)

local begin_prefetch = ya.sync(function(state, urls)
  state.linemode_latest = state.linemode_latest or {}
  state.linemode_revision = (state.linemode_revision or 0) + 1

  local revision = state.linemode_revision
  for _, url in ipairs(urls) do
    state.linemode_latest[url] = revision
  end

  return revision
end)

local finish_prefetch = ya.sync(function(state, revision, items)
  state.linemode_entries = state.linemode_entries or {}
  state.linemode_loading = state.linemode_loading or {}
  state.linemode_latest = state.linemode_latest or {}

  local now = ya.time()

  for _, item in ipairs(items) do
    if state.linemode_latest[item.url] == revision then
      local loading = state.linemode_loading[item.url]
      if not loading or loading.revision < revision then
        state.linemode_loading[item.url] = nil
        state.linemode_latest[item.url] = nil
        state.linemode_entries[item.url] = {
          sig = item.sig,
          text = item.text,
          refreshed_at = now,
        }
      end
    end
  end

  ui.render()
end)

local function render_target(cha, url, resolve)
  if cha.is_fifo then
    return "fifo"
  end

  if cha.is_sock then
    return "sock"
  end

  if cha.is_char or cha.is_block then
    return "dev"
  end

  if cha.is_dir then
    local files = fs.read_dir(url, { resolve = resolve })
    return files and tostring(#files) or "?"
  end

  return ya.readable_size(cha.len or 0)
end

local function render_text(url)
  local cha = fs.cha(url)
  if not cha then
    return "?"
  end

  if not cha.is_link then
    return render_target(cha, url, false)
  end

  if cha.is_orphan then
    return ""
  end

  local target = fs.cha(url, true)
  if not target then
    return ""
  end

  return "-> " .. render_target(target, url, true)
end

local function is_fresh(entry, sig, is_link)
  if not entry or entry.sig ~= sig then
    return false
  end

  if not is_link then
    return true
  end

  return ya.time() - (entry.refreshed_at or 0) < refresh_symlink_after_seconds
end

local function schedule_load(url, sig, file_url)
  if not begin_load(url, sig) then
    return
  end

  ya.async(function()
    local ok, text = pcall(render_text, file_url)
    if ok then
      finish_load(url, sig, text)
    else
      fail_load(url, sig)
    end
  end)
end

local M = {}

function M.prefetch(cwd)
  ya.async(function()
    local files = fs.read_dir(cwd, { resolve = false })
    if not files then
      return
    end

    local urls = {}
    for _, file in ipairs(files) do
      urls[#urls + 1] = tostring(file.url)
    end
    local revision = begin_prefetch(urls)
    local items = {}

    for _, file in ipairs(files) do
      local ok, text = pcall(render_text, file.url)
      if ok then
        items[#items + 1] = {
          url = tostring(file.url),
          sig = signature(file.cha),
          text = text,
        }
      end
    end

    finish_prefetch(revision, items)
  end)
end

function M.render(file)
  local url = tostring(file.url)
  local sig = signature(file.cha)
  local entry = get_entry(url)

  if is_fresh(entry, sig, file.cha.is_link) then
    return entry.text
  end

  schedule_load(url, sig, file.url)
  return entry and entry.text or ""
end

return M
