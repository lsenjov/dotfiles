local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { output, "WarningMsg" },
    }, true, {})
    error("lazy.nvim installation failed")
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("plugins"), {
  defaults = {
    lazy = false,
  },
  local_spec = false,
  rocks = {
    enabled = false,
  },
})
