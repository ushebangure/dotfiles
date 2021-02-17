" Basics
filetype plugin indent on
syntax on
set encoding=utf-8
set number
set shell=/bin/zsh
set backspace=indent,eol,start
set ignorecase
set smartcase
set colorcolumn=80
set cursorline
set nofoldenable
set showtabline=0

" Whitespace stuff
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅
autocmd FileType html setlocal shiftwidth=2 tabstop=2 expandtab!
autocmd FileType less setlocal shiftwidth=2 tabstop=2 expandtab!
autocmd FileType go setlocal shiftwidth=4 tabstop=4 expandtab!
autocmd BufRead,BufNewFile *.ledger setlocal shiftwidth=4 tabstop=4 expandtab!

" Close preview window once selected
autocmd CompleteDone * pclose

" Pretty colours!
syntax enable
set background=dark
:sign define dummy
:execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')
set re=1

" Plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'fatih/vim-go'
Plug 'fatih/molokai'
Plug 'mhartington/oceanic-next'
Plug 'tpope/vim-fugitive'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'neomake/neomake'
Plug 'vim-airline/vim-airline'
Plug 'Shougo/neosnippet.vim'
Plug 'sheerun/vim-polyglot'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}

" Initialize plugin system
call plug#end()

colorscheme OceanicNext

" Remaps
inoremap jk <ESC>
tnoremap <c-n><c-n> <c-\><c-n>
let mapleader = "\<Space>"
nmap <leader>w :w<CR>
nmap <leader>qq :q<CR>
nmap <leader>e :Explore<CR>
nmap <leader>n :lnext<CR>
nmap <leader>t :GitFiles<CR>
nmap <leader>gl :GoLint<CR>
nmap <leader>gb :GoBuild<CR>
nmap <leader>gt :GoTest<CR>
nmap <leader>gr :GoRename<CR>
nmap <leader>gu :GoReferrers<CR>
nmap <leader>ag :Ggr<Space>
nmap <leader>sv :vsplit<CR>
nmap <leader>sp :set paste<CR>
nmap <leader>snp :set nopaste<CR>
nmap <leader>sh :split<CR>
nmap <leader>n :noh<CR>
nmap <leader>ls :ls<CR>
nmap <leader><leader> :
nmap <leader>o o<Esc>k
nmap <leader>O O<Esc>j
nmap <leader>cc :cclose<CR>
nmap <leader>co :copen<CR>
nmap <leader>cn :cn<CR>
nmap <leader>cp :cp<CR>
nmap <leader>tt :terminal<CR>
nmap <leader>nn :tabNext<CR>
nmap <leader>np :tabprevious<CR>
nmap <leader>nt :tabnew<CR>

" Git Stuff
nmap <leader>vs :Gstatus<CR>
nmap <leader>vc :Gcommit<CR>
nmap <leader>vb :Gblame<CR>
nmap <leader>ve :Gedit<CR>
nmap <leader>vd :Gdiff<CR>
nmap <leader>dg :diffget //
nmap <leader>du :diffupdate<CR>
nmap <leader>[ [c
nmap <leader>] ]c

" Move Remaps
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Swap files in /vim
set backupdir=~/.vim/backup_files//
set directory=~/.vim/swap_files//
set undodir=~/.vim/undo_files//

" Plugin maps
map <C-n> :NERDTreeToggle<CR>

"" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_snippet_engine = ""
let g:go_def_mode = 'gopls'
let g:go_guru_scope = ['bitx/...']
let NERDTreeShowHidden=1

"" Autoformat
noremap <C-f> :Autoformat<CR>

"" neocomplete
let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3.7'
let g:deoplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
set completeopt-=preview

"" airline
set laststatus=2

"" Grepping stuff
command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw!

" neomake
autocmd BufWritePost * Neomake
let g:neomake_error_sign   = {'text': '✖', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '∆', 'texthl': 'NeomakeWarningSign'}
let g:neomake_message_sign = {'text': '➤', 'texthl': 'NeomakeMessageSign'}
let g:neomake_info_sign    = {'text': 'ℹ', 'texthl': 'NeomakeInfoSign'}
let g:neomake_go_enabled_makers = [ 'go', 'gometalinter' ]
let g:neomake_go_gometalinter_maker = {
  \ 'args': [
  \   '--tests',
  \   '--enable-gc',
  \   '--concurrency=3',
  \   '--fast',
  \   '-D', 'aligncheck',
  \   '-D', 'dupl',
  \   '-D', 'gocyclo',
  \   '-D', 'gotype',
  \   '-E', 'errcheck',
  \   '-E', 'misspell',
  \   '-E', 'unused',
  \   '%:p:h',
  \ ],
  \ 'append_file': 0,
  \ 'errorformat':
  \   '%E%f:%l:%c:%trror: %m,' .
  \   '%W%f:%l:%c:%tarning: %m,' .
  \   '%E%f:%l::%trror: %m,' .
  \   '%W%f:%l::%tarning: %m'
  \ }

" Launch gopls when Go files are in use
let g:LanguageClient_serverCommands = {
       \ 'go': ['gopls']
       \ }
" Run gofmt and goimports on save
autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

let g:neosnippet#disable_runtime_snippets = {'_':1}
let g:neosnippet#snippets_directory='~/.confing/nvim/plugged/vim-snippets/snippets'

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
