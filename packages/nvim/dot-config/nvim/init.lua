vim.g.maplocalleader = ","

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.directory = vim.fn.expand("$HOME/.vim/swapfiles//")
vim.opt.timeoutlen = 500
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.g.ale_linters = {
  clojure = { "clj-kondo" },
}
vim.g.paredit_matchlines = 10000
vim.g["conjure#mapping#log_reset_soft"] = false
vim.g["conjure#mapping#log_reset_hard"] = false

vim.api.nvim_set_hl(0, "Pmenu", {
  bg = "darkgray",
  ctermbg = 8,
})
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])

local map = vim.keymap.set

map("n", "<localleader>ffc", "<cmd>Telescope command_history<cr>")
map("n", "<localleader>fff", "<cmd>Telescope find_files<cr>")
map("n", "<localleader>ffg", "<cmd>Telescope live_grep<cr>")
map("n", "<localleader>ffm", "<cmd>Telescope man_pages<cr>")
map("n", "<localleader>ffh", "<cmd>Telescope help_tags<cr>")

map("n", "<localleader>qs", "<cmd>ConjureConnect 7000<cr>")
map("n", "<localleader>qc", "<cmd>ConjureConnect 7002<cr>:ConjureEval (shadow.cljs.devtools.api/repl :debug)")
map("n", ",et", function()
  vim.api.nvim_cmd({ cmd = "tabedit", args = { vim.fn.expand("%:p:h") .. "/" } }, {})
end)
map("n", ",es", function()
  vim.api.nvim_cmd({ cmd = "split", args = { vim.fn.expand("%:p:h") .. "/" } }, {})
end)

map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "<localleader>ld", vim.lsp.buf.declaration)
map("n", "<localleader>lt", vim.lsp.buf.type_definition)
map("n", "<localleader>lh", vim.lsp.buf.signature_help)
map("n", "<localleader>ln", vim.lsp.buf.rename)
map("n", "<localleader>le", vim.diagnostic.open_float)
map("n", "<localleader>lq", vim.diagnostic.setloclist)
map("n", "<localleader>lf", vim.lsp.buf.format)
map("n", "<localleader>lk", vim.diagnostic.open_float)
map({ "n", "x" }, "<localleader>la", vim.lsp.buf.code_action)
map("n", "<localleader>lw", function()
  require("telescope.builtin").diagnostics()
end)
map("n", "<localleader>lr", function()
  require("telescope.builtin").lsp_references()
end)
map("n", "<localleader>li", function()
  require("telescope.builtin").lsp_implementations()
end)

map("n", "<c-n>", "<cmd>FocusSplitCycle<cr>")
map("n", "<c-p>", "<cmd>FocusSplitCycle reverse<cr>")
map("n", "<c-M-n>", "<cmd>tabnext<cr>")
map("n", "<c-M-p>", "<cmd>tabprevious<cr>")

vim.cmd([[silent! aunmenu PopUp.How-to\ disable\ mouse]])
vim.cmd([[silent! aunmenu PopUp.-1-]])

require("codex_chat").setup()
require("config.lazy")
