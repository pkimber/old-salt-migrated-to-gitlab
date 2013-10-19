set nocompatible               " be iMproved
filetype off                   " required!
filetype plugin indent on      " required!

" ----------------------------------------------------------------------------
" Change the mapleader from \ to ,
" let mapleader=","

set list
" Use ':set list' to switch this back on (if it gets switched off).
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·

" ----------------------------------------------------------------------------
" allow background buffer + marks and undo-history are remembered.
set hidden
" longer history
set history=1000
" switch on line numbers (removed so I can get 3 columns of 80 chars).
" set number
" switch wrapping off.
set nowrap
" number of space characters that will be inserted when the tab key is pressed.
set tabstop=4
" change the number of space characters inserted for indentation.
set shiftwidth=4
" insert space characters whenever the tab key is pressed.
set expandtab
" *****************************************************************************

" number of spaces that a tab counts for while performing editing operations.
set softtabstop=4
" set the backup folder.
set backupdir=~/repo/temp/backup-vim/,~/temp/
" set the swap file folder.
set directory=~/repo/temp/backup-vim/,~/temp/
" switch on auto indent.
set autoindent
" visual bell
set visualbell
" backspace key wasn't working
set backspace=2
" syntax
syntax on
" see ~/.gvimrc for the gvim colour scheme
colorscheme desert

" Search options:
" search case-insensitive if enter string in ALL lower case.
set ignorecase
" highlight all search pattern matches
" set hlsearch
" override ignorecase option if search pattern contains upper case.
set smartcase

" start the scrolling three lines before the border
set scrolloff=3
" Make file/command completion useful - http://items.sjbach.com/319/configuring-vim-right
set wildmenu
set wildmode=list:longest
" http://stackoverflow.com/questions/235439/vim-80-column-layout-concerns
set colorcolumn=80

" ----------------------------------------------------------------------------
" scroll the viewport faster.
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
" swap tick and back-tick (http://items.sjbach.com/319/configuring-vim-right)
nnoremap ' `
nnoremap ` '
