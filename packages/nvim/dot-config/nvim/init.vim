

"id16873
" Fold method
set fdm=syntax
" Make tabs 2 spaces. You don't need more
set shiftwidth=2
set tabstop=2
" Set number and relative numbers on the side
set number relativenumber

" A place for all the swapfiles to go, instead of locally
set directory=$HOME/.vim/swapfiles//
"id16873 end

"id28020
" Install vimplug if it's not already
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'neovim/nvim-lspconfig'

" Automatic resizing of tabs
"Plug 'zhaocai/GoldenView.Vim'
Plug 'nvim-focus/focus.nvim'

" Conjure
Plug 'Olical/conjure'

" Conjure support - jack-in with nrepl dependencies
Plug 'tpope/vim-dispatch'
Plug 'clojure-vim/vim-jack-in'
" Only in Neovim:
Plug 'radenling/vim-dispatch-neovim'

" clj-kondo support
Plug 'dense-analysis/ale'

" Preeeeetty
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'vim-syntastic/syntastic'

" Paredit
Plug 'vim-scripts/paredit.vim'
"Plug 'Shougo/deoplete.nvim' "deprecated

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'vim-autoformat/vim-autoformat'

" trouble - for displaying listings of errors
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/trouble.nvim'

" show git blame on every line
" Turn on with :GitBlameToggle
Plug 'f-person/git-blame.nvim'
Plug 'lewis6991/gitsigns.nvim'

" Turn lsp up to 11
" Plug 'neovim/nvim-lspconfig' " already installed above
" Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }
" Plug 'ray-x/navigator.lua'

" Startup screen
Plug 'nvimdev/dashboard-nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MaximilianLloyd/ascii.nvim'

" Experimental funtimes with blinging windows
" Plug 'folke/noice.nvim'
Plug 'MunifTanjim/nui.nvim' " Needed for ascii as well as noice
Plug 'rcarriga/nvim-notify'

" Show what your key combo is doing
Plug 'folke/which-key.nvim'

" Project manager
Plug 'coffebar/neovim-project'
Plug 'Shatur/neovim-session-manager'

" Automatically make directories when saving a file if they don't exist
Plug 'pezcoder/auto-create-directory.nvim'

" formatting
Plug 'stevearc/conform.nvim'

call plug#end()
"id28020 end

" which-key relies on timeout for popping up
" If not using which-key, remove this
set timeoutlen=500

:match ExtraWhitespace /\s\+$/

" Lint configuration - clj-kondo
" clj-kondo should be installed on operating system path
let g:ale_linters = {
      \ 'clojure': ['clj-kondo']
      \}

" By default this is 100
" So it kinda dies trying to match beyond this
" And sometimes (especially pages) are much larger
let g:paredit_matchlines = 10000

let g:conjure#mapping#log_reset_soft = v:false
let g:conjure#mapping#log_reset_hard = v:false

:let maplocalleader = ","
nnoremap <localleader>ffc :Telescope command_history<CR>
nnoremap <localleader>fff :Telescope find_files<CR>
nnoremap <localleader>ffg :Telescope live_grep<CR>
nnoremap <localleader>ffm :Telescope man_pages<CR>
nnoremap <localleader>ffh :Telescope help_tags<CR>

:highlight Pmenu ctermbg=darkgray guibg=darkgray

nnoremap <localleader>qs :ConjureConnect 7000 <CR>
nnoremap <localleader>qc :ConjureConnect 7002 <CR> :ConjureEval (shadow.cljs.devtools.api/repl :debug)
map ,et :tabe <C-R>=expand("%:p:h") . "/" <CR> <CR>
map ,es :split <C-R>=expand("%:p:h") . "/" <CR> <CR>

nnoremap gd <Cmd>lua vim.lsp.buf.definition()<CR>
nnoremap K <Cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <localleader>ld <Cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <localleader>lt <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <localleader>lh <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <localleader>ln <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <localleader>le <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <localleader>lq <cmd>lua vim.diagnostic.setloclist()<CR>
nnoremap <localleader>lf <cmd>lua vim.lsp.buf.format()<CR>
"nnoremap <localleader>lj <cmd>lua vim.diagnostic.jump({count = 1})<CR>
nnoremap <localleader>lk <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <localleader>la <cmd>lua vim.lsp.buf.code_action()<CR>
vnoremap <localleader>la <cmd>lua vim.lsp.buf.range_code_action()<CR>
nnoremap <localleader>lw <cmd>lua require('telescope.builtin').diagnostics()<cr>
nnoremap <localleader>lr <cmd>lua require('telescope.builtin').lsp_references()<cr>
nnoremap <localleader>li <cmd>lua require('telescope.builtin').lsp_implementations()<cr>
nnoremap <c-n> <Cmd>FocusSplitCycle<CR>
nnoremap <c-p> <Cmd>FocusSplitCycle reverse<CR>
nnoremap <c-M-n> <Cmd>tabn<CR>
nnoremap <c-M-p> <Cmd>tabp<CR>

" Use treesitter to figure out folds
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Remove the how to disable mouse warning
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-1-
