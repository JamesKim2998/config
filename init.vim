set nocompatible
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on

call plug#begin('~/.config/nvim/plugged')

Plug 'altercation/vim-colors-solarized'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'ervandew/supertab'

Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'

Plug 'rking/ag.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'tfnico/vim-gradle'
" TODO
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'

call plug#end()

" color scheme
let g:solarized_termcolors=256
set background=dark
colorscheme solarized

" indenting
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set list
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2

" ui config
set number
set showcmd
set cursorline
set showmatch

" movement
nnoremap j gj
nnoremap k gk
nnoremap B ^
nnoremap E $
nnoremap $ <nop>
nnoremap ^ <nop>

" etc
set scrolloff=15
set clipboard=unnamed

" leader shortcuts
let mapleader=","
inoremap jk <esc>
inoremap kj <esc>

" nerd tree
map <C-n> :NERDTreeFind<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" indent guide
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :IndentGuidesEnable
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=235
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=236

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
