require("trouble").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

-- Slow AF
-- require("navigator").setup({
-- })

require("gitblame").setup({
    enabled = false,
})

require("dashboard").setup({
  theme = 'doom',
	config = {
		header = require('ascii').art.text.neovim.bloody,
		center = {
			-- Broken because probably https://github.com/coffebar/neovim-project/issues/36
			-- Or maybe I'm just doing something wrong with it
			--{
			--	desc = 'Last project',
			--	desc_hl = 'String',
			--	group = 'Projects',
			--	key = 'l',
			--	action = ':NeovimProjectLoadRecent'
			--},
			{
				desc = 'Recent projects',
				desc_hl = 'String',
				group = 'Projects',
				key = 'r',
				action = ':Telescope neovim-project history'
			},
			{
				desc = 'All projects',
				desc_hl = 'String',
				group = 'Projects',
				key = 'a',
				action = ':Telescope neovim-project discover'
			},
			{
				desc = 'Plug Update',
				key = 'u',
				action = ':PlugUpdate'
			}
		}
	}
})

-- Noice is nice... but also screws with performance badly
-- require("noice").setup({
--   lsp = {
-- 		hover = { enabled = true },
--     -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--     override = {
--       ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--       ["vim.lsp.util.stylize_markdown"] = true,
--       ["cmp.entry.get_documentation"] = false, -- requires hrsh7th/nvim-cmp
--     },
--   },
-- 	cmdline = {
-- 		view = 'cmdline'
-- 	},
--   -- you can enable a preset for easier configuration
--   -- presets = {
--   --   bottom_search = true, -- use a classic bottom cmdline for search
--   --   command_palette = true, -- position the cmdline and popupmenu together
--   --   long_message_to_split = true, -- long messages will be sent to a split
--   --   inc_rename = false, -- enables an input dialog for inc-rename.nvim
--   --   lsp_doc_border = false, -- add a border to hover docs and signature help
--   -- },
-- 	throttle = 1000/5,
-- })

require("which-key").setup({
})

-- require('session_manager').setup({
-- 	 autoload_mode = require('session_manager.config').AutoloadMode.Disabled
-- })

require("neovim-project").setup({
  projects = {
	  "~/code/*/*",
		"~/.config/nvim",
		"~/.config/kitty"
	},
	dashboard_mode = true
})

require("notify").setup({
	render = 'minimal'
})

require("focus").setup({
    enable = true, -- Enable module
    commands = true, -- Create Focus commands
    autoresize = {
        enable = true, -- Enable or disable auto-resizing of splits
        width = 0, -- Force width for the focused window
        height = 0, -- Force height for the focused window
        minwidth = 0, -- Force minimum width for the unfocused window
        minheight = 0, -- Force minimum height for the unfocused window
        height_quickfix = 10, -- Set the height of quickfix panel
    },
    split = {
        bufnew = false, -- Create blank buffer for new split windows
        tmux = false, -- Create tmux splits instead of neovim splits
    },
    ui = {
        number = false, -- Display line numbers in the focussed window only
        relativenumber = false, -- Display relative line numbers in the focussed window only
        hybridnumber = false, -- Display hybrid line numbers in the focussed window only
        absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

        cursorline = true, -- Display a cursorline in the focussed window only
        cursorcolumn = false, -- Display cursorcolumn in the focussed window only
        colorcolumn = {
            enable = false, -- Display colorcolumn in the foccused window only
            list = '+1', -- Set the comma-saperated list for the colorcolumn
        },
        signcolumn = true, -- Display signcolumn in the focussed window only
        winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
    }
})

-- vim.lsp.config('clojure_lsp', {})
vim.lsp.enable('clojure_lsp')
vim.lsp.enable('ruff')

vim.keymap.set('n', '<c-l>', function()
    require('focus').split_nicely()
end, { desc = 'split nicely' })


-- START lsp formatter

require("conform").setup({
	formatters = {
		zprint = {
			command = "/home/logan/code/cubiko/cubiko-manage/bin/format/zprint"
		}
	},
  formatters_by_ft = {
    clojure = { "zprint" },
    -- Conform will run multiple formatters sequentially
    --python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    --rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    --javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- END lsp formatter

require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = true,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  blame_formatter = nil, -- Use default
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
