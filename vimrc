" Can not use the next setting with tmux
set t_Co=256 

" Save buffer list
set viminfo='20,\"500,%

colorscheme koehler
" colorscheme bubblegum
" statusline with koehler colors is hard to read when using splits
highlight StatusLine   cterm=bold ctermbg=darkgray ctermfg=lightgreen
highlight StatusLineNC cterm=NONE ctermbg=darkgray ctermfg=darkgreen

" Do not set ts=2, if does, can't really tell the difference between
" tab/space. It will be easy to tell someone mess up the coding style.
set ai sts=2 et
set sw=2
set tw=0

" reset all mappings
mapclear

" Leader
let mapleader = ","

" reset all autocmd
""au!

set mouse=a
set ttymouse=xterm2
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize
" http://www.linux.com/archive/articles/54936
imap <F6> <ESC>:set ttym=xterm2<CR>
nmap <F6> <ESC>:set ttym=xterm2<CR>
imap <F6><F6> <ESC>:set ttym=<CR>
nmap <F6><F6> <ESC>:set ttym=<CR>

imap <F3> <ESC>:set hlsearch! hlsearch?<CR><INSERT><RIGHT>
nmap <F3> :set hlsearch! hlsearch?<CR>

imap <F4> <C-R>=strftime("%FT%TZ", localtime()-8*3600)<CR>
nmap <F4> "=strftime("%FT%TZ", localtime()-8*3600)<CR>p

" Fix key control codes
map [31~ <S-F7>

" Spell check
map <F7> <ESC>:setlocal spell! spelllang=en_us<CR>

set pastetoggle=<F12>
set modeline

set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words

" ==========================================================================
" Python
" ==========================================================================

" For Python source
" autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
autocmd BufRead *.py set tabstop=2
autocmd BufRead *.py set smarttab
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``

" ==========================================================================
" ==========================================================================

" Set shell title
" http://vim.wikia.com/wiki/Automatically_set_screen_title
let &titlestring = "vim:" . expand("%:t")
if &term == "screen"
  " ^[ is by pressing Ctrl+V ESC
  set t_ts=k
  set t_fs=\
endif
if &term == "screen" || &term == "xterm" || &term == "urxvt"
  set title
endif

" ==========================================================================
" Markdown syntax
" ==========================================================================

" http://plasticboy.com/markdown-vim-mode/
augroup mkd

  autocmd BufRead *.mkd set tabstop=2
  autocmd BufRead *.mkd set shiftwidth=2
  autocmd BufRead *.mkd set smarttab
  autocmd BufRead *.mkd set expandtab
  autocmd BufRead *.mkd set softtabstop=2

  autocmd BufRead *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;

  autocmd BufRead *.mkd  map <F5> <ESC>:w<CR>:exec '!b.py generate ' . shellescape(expand('%:p'))<CR>
  autocmd BufRead *.mkd imap <F5> <ESC>:w<CR>:exec '!b.py generate ' . shellescape(expand('%:p'))<CR>

  autocmd BufRead *.mkd nmap <Leader>post <ESC>:w<CR>:exec '!b.py post ' . shellescape(expand('%:p'))<CR>
  autocmd BufRead *.mkd nmap <Leader>chk <ESC>:w<CR>:exec '!b.py checklink ' . shellescape(expand('%:p'))<CR>

augroup END

" ==========================================================================
" rst
" ==========================================================================

augroup rst

  autocmd BufRead *.rst  map <F5> <ESC>:w<CR>:exec '!b.py generate ' . shellescape(expand('%:p'))<CR>
  autocmd BufRead *.rst imap <F5> <ESC>:w<CR>:exec '!b.py generate ' . shellescape(expand('%:p'))<CR>

  autocmd BufRead *.rst nmap <Leader>post <ESC>:w<CR>:exec '!b.py post ' . shellescape(expand('%:p'))<CR>
  autocmd BufRead *.rst nmap <Leader>chk <ESC>:w<CR>:exec '!b.py checklink ' . shellescape(expand('%:p'))<CR>

augroup END

" ==========================================================================
" https://github.com/xolox/vim-notes
" ==========================================================================

let g:notes_directory = '~/Documents/VimNotes'
let g:notes_tagsindex = '~/Documents/VimNotes/tags.txt'

" ==========================================================================

" For setting current directory
nnoremap , cd : cd %:p:h<CR>:pwd<CR>
nnoremap ,lcd :lcd %:p:h<CR>:pwd<CR>

" Easy out in insert mode
imap <C-j> <Esc>

" For reload vimrc quick
nmap <Leader>ev :tabnew ~/.vimrc<CR>
nmap <Leader>rv :source ~/.vimrc<CR>

" Buffers
nmap <Leader>ls :ls<CR>
nmap <Leader>bp :bp<CR>
nmap <Leader>bn :bn<CR>
nmap <Leader>bw :bw<CR>
nmap <Leader>bb :b#<CR>
nmap <Leader>b# :b#<CR>

" ==========================================================================
" Notes
" ==========================================================================

nmap <Leader>todo :Note ToDo<CR>

" ==========================================================================
" Clipboard
" ==========================================================================
" shortcuts for copying to clipboard
nmap <leader>y "+y

" copy the current line to the clipboard
nmap <leader>Y "+yy
nmap <leader>p "+p
nmap <leader>P "+P

" ==========================================================================
" HTML Encode/Decode
" ==========================================================================
" ref: http://vim.wikia.com/wiki/HTML_entities#Perl_HTML::Entities
function! HTMLEncode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = encode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction

function! HTMLDecode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = decode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction

vmap <Leader>h :call HTMLEncode()<CR>
vmap <Leader>H :call HTMLDecode()<CR>

" ==========================================================================
" FileTypes
" ==========================================================================

au BufEnter * lcd %:p:h

" vim: set sw=2 et:
