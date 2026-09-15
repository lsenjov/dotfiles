# Neovim Codex chat

## Implementation phase

1. Add a small Lua module that opens one listed Markdown scratch buffer per Git
   project in the current window without changing the source buffer.
2. Track the bottom draft with an extmark and send it asynchronously to Codex
   in read-only mode, resuming only the explicit thread ID returned by Codex.
3. Keep the chat buffer unmodifiable while a request is pending, append replies
   and errors safely, and handle duplicate sends or deleted buffers.
4. Load the module from `init.lua`, then validate startup and the initial,
   resumed, error, path, and buffer-lifecycle behavior with a stubbed process.
5. Complete independent review with no high- or medium-severity findings.

## Completion and validation

- `:Codex` opens the project chat in the current window. Normal-mode
  `<localleader>ec` (`,ec`) sends the bottom draft. Visual-mode `,ec` sends a
  source selection to the same project chat while keeping focus on the source.
- Temporary headless harnesses passed for initial and explicit-ID resumed
  turns, roots containing spaces, unsaved source buffers, heading-like text,
  duplicate sends, CLI errors, deleted and unloaded buffers, and undo behavior.
- Visual mapping tests passed for linewise, multibyte characterwise, and
  blockwise selections, hidden-chat responses, unchanged source focus, busy
  chats, existing drafts, and reselected unloaded buffers.
- A temporary fake `codex` executable passed an actual asynchronous
  `vim.system` check of stdin, working directory, read-only/model flags, and
  response handling. No live model request was made.
- `nvim --headless -u packages/nvim/dot-config/nvim/init.lua +qa` and
  `git diff --check` passed.
- `uv run --no-project --with pyyaml scripts/test` passed. Optional ShellCheck
  and Gitleaks checks were skipped because those tools are unavailable.
- The Markdown transcript exists only in the live Neovim buffer. Codex keeps
  its normal CLI session data so explicit thread-ID follow-ups work; no
  transcript or session file is written to the project.
- Final review found no high-, medium-, or low-severity issues. Earlier undo
  alignment and unloaded-buffer findings were fixed and regression tested.
