" my .vimrc
"
" author: Yu-Jie Lin
" web   : https://github.com/livibetter/dotfiles/blob/master/vimrc
"
" note: if you know any way to improve this file, please open an issue on
"       GitHub or contact me via http://s.yjl.im/contact

" pathogen.vim
execute pathogen#infect()

"=========="
" Settings "
"=========="

colorscheme desert

" Others
"========

" no intro message
set shortmess+=I

set hidden

" Save buffer list
set viminfo='20,\"500,%

set autoindent
set tabstop=8
set softtabstop=4
set expandtab
set smarttab
set shiftwidth=4
set textwidth=0

set mouse=a
set ttymouse=xterm2
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize

set pastetoggle=<F12>
set modeline

set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words

"============="
" keymappings "
"============="

mapclear
let mapleader = ","

" Easy way out from insert mode

imap <C-j> <Esc>

imap <F3> <ESC>:set hlsearch! hlsearch?<CR><INSERT><RIGHT>
nmap <F3>      :set hlsearch! hlsearch?<CR>

imap <F4> <C-R>=strftime("%FT%TZ", localtime()-8*3600)<CR>
nmap <F4>     "=strftime("%FT%TZ", localtime()-8*3600)<CR>p

" Spell check

imap <F7> <ESC>:setlocal spell! spelllang=en_us<CR>
nmap <F7> <ESC>:setlocal spell! spelllang=en_us<CR>

" For setting current directory

nnoremap <LEADER> cd : cd %:p:h<CR>:pwd<CR>
nnoremap <LEADER>lcd :lcd %:p:h<CR>:pwd<CR>

" For reload vimrc quick

nmap <LEADER>ev :tabnew ~/.vimrc<CR>
nmap <LEADER>rv :source ~/.vimrc<CR>

" Buffers

nmap <LEADER>ls :ls<CR>
nmap <LEADER>bp :bp<CR>
nmap <LEADER>bn :bn<CR>
nmap <LEADER>bw :bw<CR>
nmap <LEADER>bb :b#<CR>
nmap <LEADER>b# :b#<CR>

" Clipboard

nmap <LEADER>y "+y
nmap <LEADER>Y "+yy
nmap <LEADER>p "+p
nmap <LEADER>P "+P

"============"
" some stuff "
"============"

augroup fixes

  autocmd!

  autocmd BufEnter * lcd %:p:h

  " Set shell title
  " http://vim.wikia.com/wiki/Automatically_set_screen_title
  "==========================================================

  autocmd BufEnter * let &titlestring = 'vim:' . expand('%:t')
  if &term =~ '\(st\|xterm\).*'
    set title
  endif

  " CSS
  "=====

  autocmd BufEnter * if &filetype =~ 'css\|html' | call SortCSSCmd() | endif

  " Markdown
  "==========

  autocmd BufRead *.md,*.mkd set filetype=markdown

  " fenced code block
  autocmd BufRead * if &filetype == 'markdown'
    \ | syn region markdownCode matchgroup=markdownCodeDelimiter
    \   start="``` \="
    \   end=" \=```" keepend contains=markdownLineStart
    \ | endif

  " W
  " =
  " Only text files and files without extensions under ~/Document/w.txt

  autocmd BufRead *
    \ if &filetype == 'text'
    \ || (  &filetype != 'gitcommit'
    \    && expand('%:e') == ''
    \    && expand('%:p:h') =~ expand('$HOME') . '/Documents/w.txt'
    \    )
    \ | let &l:textwidth = 78
    \ | let &l:colorcolumn = &textwidth + 1
    \ | setlocal formatoptions=qwa2t
    \ | setlocal spell spelllang=en_us
    \ | hi ColorColumn ctermbg=lightgrey guibg=lightgrey
    \ | endif

augroup END

"================================================="
" boxes comments <http://boxes.thomasjensen.com/> "
"================================================="

augroup boxes

  autocmd!

  autocmd BufRead .boxes,boxes-config set filetype=boxes

  autocmd BufRead * call BoxesMap()

augroup END

function! BoxesMap()

  if &filetype =~ '^\(boxes\|conf\|make\|python\|sh\)$'
    let boxestype = 'pound'
  elseif &filetype =~ '^\(c\|css\|javascript\)$'
    let boxestype = 'c'
  elseif &filetype =~ 'vim\|pentadactyl'
    let boxestype = 'vim'
  else
    return
  endif

  for [key, type] in [['a', 'h1'] , ['b', 'h2'], ['c', 'cmt']]
    let t = type . '-' . boxestype
    for [keypx, optr] in [['c', ''], ['C', ' -r']]
      let k = keypx . key
      for maptype in ['nmap', 'vmap']
        let m = ':' . maptype . ' <buffer> <LEADER>'
        exec m . k . ' !!boxes -d ' . t . optr . '<CR>'
        exec m . k . '  !boxes -d ' . t . optr . '<CR>'
      endfor
    endfor
  endfor

endfunction

"===================================="
" https://github.com/xolox/vim-notes "
"===================================="

let g:notes_directories = ['~/Documents/VimNotes']
let g:notes_tagsindex = '~/Documents/VimNotes/tags.txt'
let g:notes_conceal_italic = 0
let g:notes_conceal_bold = 0
let g:notes_conceal_url = 0

nmap <LEADER>todo :Note ToDo<CR>

" using command-line-only abbrev to alias Note
cabbrev note Note

" ================================================================== "
" Open fold navigation                                               "
" Based on: http://vim.wikia.com/wiki/Navigate_to_the_next_open_fold "
" ================================================================== "

function! GoToOpenFold(direction)
  if (a:direction == "next")
    normal zj
    let start = line('.')
    while (foldclosed(start) != -1)
      let start = start + 1
    endwhile
  else
    normal zk
    let start = line('.')
    while (foldclosed(start) != -1)
      let start = start - 1
    endwhile
  endif
  call cursor(start, 0)
endfunction
nmap zJ :call GoToOpenFold("next")<CR>
nmap zK :call GoToOpenFold("prev")<CR>
