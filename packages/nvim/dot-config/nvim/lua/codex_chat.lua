local M = {}

local api = vim.api
local draft_namespace = api.nvim_create_namespace("codex_chat_draft")
local chats = {}

local function notify(message, level)
  vim.notify("Codex: " .. message, level or vim.log.levels.INFO)
end

local function root_for_buffer(bufnr)
  local existing = vim.b[bufnr].codex_chat_root
  if existing then
    return existing
  end

  return vim.fs.root(bufnr, ".git")
end

local function draft_lines(state)
  local position = api.nvim_buf_get_extmark_by_id(state.bufnr, draft_namespace, state.draft_mark, {})
  if #position == 0 then
    return nil
  end

  local lines = api.nvim_buf_get_lines(state.bufnr, position[1], -1, false)
  local first = 1
  local last = #lines
  while first <= last and lines[first]:match("^%s*$") do
    first = first + 1
  end
  while last >= first and lines[last]:match("^%s*$") do
    last = last - 1
  end

  if first > last then
    return ""
  end
  return table.concat(vim.list_slice(lines, first, last), "\n")
end

local function mark_draft(state)
  api.nvim_buf_clear_namespace(state.bufnr, draft_namespace, 0, -1)
  local row = api.nvim_buf_line_count(state.bufnr) - 1
  state.draft_mark = api.nvim_buf_set_extmark(state.bufnr, draft_namespace, row, 0, {
    right_gravity = false,
  })
end

local function append_result(state, heading, content)
  if
    chats[state.root] ~= state
    or not api.nvim_buf_is_valid(state.bufnr)
    or not api.nvim_buf_is_loaded(state.bufnr)
    or state.stale
  then
    notify("response discarded because the chat buffer was closed", vim.log.levels.WARN)
    return
  end

  local lines = { "", "## " .. heading, "" }
  vim.list_extend(lines, vim.split(content, "\n", { plain = true }))
  vim.list_extend(lines, { "", "## You", "" })

  local undolevels = vim.bo[state.bufnr].undolevels
  vim.bo[state.bufnr].modifiable = true
  vim.bo[state.bufnr].undolevels = -1
  api.nvim_buf_set_lines(state.bufnr, -1, -1, false, lines)
  vim.bo[state.bufnr].undolevels = undolevels
  mark_draft(state)
  state.busy = false

  if api.nvim_get_current_buf() == state.bufnr then
    api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(state.bufnr), 0 })
  end
end

local function decode_response(stdout)
  local thread_id
  local answers = {}
  local reported_error

  for line in (stdout or ""):gmatch("[^\r\n]+") do
    local ok, event = pcall(vim.json.decode, line)
    if ok and type(event) == "table" then
      if event.type == "thread.started" then
        thread_id = event.thread_id
      elseif
        event.type == "item.completed"
        and event.item
        and event.item.type == "agent_message"
        and type(event.item.text) == "string"
      then
        table.insert(answers, event.item.text)
      elseif event.type == "error" then
        reported_error = event.message
      elseif event.type == "turn.failed" and event.error then
        reported_error = event.error.message
      end
    end
  end

  return thread_id, table.concat(answers, "\n\n"), reported_error
end

local function command_for(state)
  local command = {
    "codex",
    "--ask-for-approval",
    "never",
    "exec",
    "--sandbox",
    "read-only",
    "--model",
    "gpt-5.6-luna",
    "--json",
    "--cd",
    state.root,
  }

  if state.thread_id then
    vim.list_extend(command, { "resume", state.thread_id, "-" })
  else
    table.insert(command, "-")
  end
  return command
end

local function finish(state, result)
  local thread_id, answer, reported_error = decode_response(result.stdout)
  state.thread_id = thread_id or state.thread_id

  if result.code ~= 0 or answer == "" then
    local message = reported_error or vim.trim(result.stderr or "")
    if message == "" then
      message = result.code == 0 and "Codex returned no answer." or ("Codex exited with code " .. result.code .. ".")
    end
    append_result(state, "Error", message)
    return
  end

  append_result(state, "Codex", answer)
end

function M.send(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local root = vim.b[bufnr].codex_chat_root
  local state = root and chats[root]
  if not state or state.bufnr ~= bufnr then
    notify("the current buffer is not a Codex chat", vim.log.levels.ERROR)
    return
  end
  if state.busy then
    notify("a request is already running", vim.log.levels.WARN)
    return
  end

  local question = draft_lines(state)
  if question == nil then
    notify("the draft marker is missing; reopen the chat", vim.log.levels.ERROR)
    return
  end
  if question == "" then
    notify("write a question below the final `## You` heading", vim.log.levels.WARN)
    return
  end

  state.busy = true
  vim.bo[bufnr].modifiable = false
  local ok, process = pcall(vim.system, command_for(state), {
    cwd = state.root,
    stdin = question,
    text = true,
  }, function(result)
    vim.schedule(function()
      finish(state, result)
    end)
  end)

  if not ok then
    append_result(state, "Error", tostring(process))
  else
    notify("asking Luna…")
  end
end

local function create_chat(root)
  local bufnr = api.nvim_create_buf(true, true)
  local state = {
    root = root,
    bufnr = bufnr,
    busy = false,
  }
  chats[root] = state

  api.nvim_buf_set_name(bufnr, "codex://" .. root)
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].swapfile = false
  vim.b[bufnr].codex_chat_root = root
  api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "# Codex Chat",
    "",
    "Project: " .. root,
    "",
    "Write a question below, then press `,ec` in Normal mode.",
    "",
    "## You",
    "",
  })
  mark_draft(state)

  vim.keymap.set("n", "<localleader>ec", function()
    M.send(bufnr)
  end, { buffer = bufnr, desc = "Send Codex question" })

  api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    buffer = bufnr,
    callback = function()
      if chats[root] == state then
        chats[root] = nil
      end
    end,
  })
  api.nvim_create_autocmd("BufUnload", {
    buffer = bufnr,
    callback = function()
      if chats[root] == state then
        state.stale = true
      end
    end,
  })

  return state
end

local function chat_for_root(root)
  root = vim.fs.normalize(root)
  local state = chats[root]
  local unloaded = state and api.nvim_buf_is_valid(state.bufnr) and not api.nvim_buf_is_loaded(state.bufnr)
  if state and (state.stale or unloaded) then
    if api.nvim_buf_is_valid(state.bufnr) then
      api.nvim_buf_delete(state.bufnr, { force = true })
    end
    state = nil
  end
  if not state or not api.nvim_buf_is_valid(state.bufnr) then
    state = create_chat(root)
  end
  return state
end

function M.open()
  local source = api.nvim_get_current_buf()
  local root = root_for_buffer(source)
  if not root then
    notify("the source buffer is not inside a Git repository", vim.log.levels.ERROR)
    return
  end

  local state = chat_for_root(root)
  api.nvim_win_set_buf(0, state.bufnr)
  api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(state.bufnr), 0 })
end

function M.send_selection()
  local source = api.nvim_get_current_buf()
  if vim.b[source].codex_chat_root then
    notify("send chat drafts with `,ec` in Normal mode", vim.log.levels.WARN)
    return
  end

  local root = root_for_buffer(source)
  if not root then
    notify("the source buffer is not inside a Git repository", vim.log.levels.ERROR)
    return
  end

  local ok, selection = pcall(vim.fn.getregion, vim.fn.getpos("v"), vim.fn.getpos("."), {
    type = vim.fn.mode(),
  })
  if not ok or #selection == 0 then
    notify("could not read the visual selection", vim.log.levels.ERROR)
    return
  end

  local state = chat_for_root(root)
  if state.busy then
    notify("a request is already running for this project", vim.log.levels.WARN)
    return
  end

  local draft = draft_lines(state)
  if draft == nil then
    notify("the chat draft marker is missing; reopen the chat", vim.log.levels.ERROR)
    return
  end
  if draft ~= "" then
    notify("the project chat already has an unsent draft", vim.log.levels.WARN)
    return
  end

  local position = api.nvim_buf_get_extmark_by_id(state.bufnr, draft_namespace, state.draft_mark, {})
  api.nvim_buf_set_lines(state.bufnr, position[1], -1, false, selection)
  M.send(state.bufnr)
end

function M.setup()
  api.nvim_create_user_command("Codex", M.open, {
    desc = "Open the project Codex chat",
  })
  vim.keymap.set("x", "<localleader>ec", M.send_selection, {
    desc = "Send selection to project Codex chat",
  })
end

return M
