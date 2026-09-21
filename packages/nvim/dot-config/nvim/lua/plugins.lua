return {
  { "folke/lazy.nvim", tag = "stable" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          if client.name == "rust_analyzer" and client:supports_method("textDocument/completion") then
            vim.bo[args.buf].completeopt = "menuone,noselect,popup"
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })

      vim.lsp.enable("clojure_lsp")
      vim.lsp.enable("ruff")
      vim.lsp.enable("rust_analyzer")
    end,
  },
  {
    "nvim-focus/focus.nvim",
    lazy = false,
    opts = {
      enable = true,
      commands = true,
      autoresize = {
        enable = true,
        width = 0,
        height = 0,
        minwidth = 0,
        minheight = 0,
        height_quickfix = 10,
      },
      split = {
        bufnew = false,
        tmux = false,
      },
      ui = {
        number = false,
        relativenumber = false,
        hybridnumber = false,
        absolutenumber_unfocussed = false,
        cursorline = true,
        cursorcolumn = false,
        colorcolumn = {
          enable = false,
          list = "+1",
        },
        signcolumn = true,
        winhighlight = false,
      },
    },
    keys = {
      {
        "<c-l>",
        function()
          require("focus").split_nicely()
        end,
        desc = "Split nicely",
      },
    },
  },
  { "Olical/conjure" },
  { "tpope/vim-dispatch" },
  {
    "clojure-vim/vim-jack-in",
    dependencies = { "tpope/vim-dispatch" },
  },
  {
    "radenling/vim-dispatch-neovim",
    dependencies = { "tpope/vim-dispatch" },
  },
  { "dense-analysis/ale" },
  { "vim-airline/vim-airline" },
  {
    "vim-airline/vim-airline-themes",
    dependencies = { "vim-airline/vim-airline" },
  },
  { "vim-syntastic/syntastic" },
  { "vim-scripts/paredit.vim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  { "vim-autoformat/vim-autoformat" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "f-person/git-blame.nvim",
    opts = {
      enabled = false,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged_enable = true,
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
        ignore_whitespace = true,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      blame_formatter = nil,
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      {
        "MaximilianLloyd/ascii.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
      },
    },
    opts = function()
      return {
        theme = "doom",
        config = {
          header = require("ascii").art.text.neovim.bloody,
          center = {
            {
              desc = "Recent projects",
              desc_hl = "String",
              group = "Projects",
              key = "r",
              action = ":Telescope neovim-project history",
            },
            {
              desc = "All projects",
              desc_hl = "String",
              group = "Projects",
              key = "a",
              action = ":Telescope neovim-project discover",
            },
            {
              desc = "Lazy update",
              key = "u",
              action = ":Lazy update",
            },
          },
        },
      }
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "minimal",
    },
  },
  {
    "folke/which-key.nvim",
    opts = {},
  },
  {
    "coffebar/neovim-project",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "Shatur/neovim-session-manager",
    },
    opts = {
      projects = {
        "~/code/*/*",
        "~/.config/nvim",
        "~/.config/kitty",
      },
      dashboard_mode = true,
    },
  },
  { "pezcoder/auto-create-directory.nvim" },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        zprint = {
          command = "/home/logan/code/cubiko/cubiko-manage/bin/format/zprint",
        },
      },
      formatters_by_ft = {
        clojure = { "zprint" },
        rust = { "rustfmt" },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}
