set nocompatible
set backspace=2

" ----------------------------------------------------------------------------
" Source the vimrc file after saving it
" ----------------------------------------------------------------------------
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

set viminfo='20,\"500   " Keep a .viminfo file.

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
        \ if ! exists("g:leave_my_cursor_position_alone") |
        \     if line("'\"") > 0 && line ("'\"") <= line("$") |
        \         exe "normal g'\"" |
        \     endif |
        \ endif

filetype plugin on
syntax on
filetype indent on
" allow unsaved background buffers and remember marks/undo for them
set hidden
set paste
set ruler

set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
" This makes RVM work inside Vim. I have no idea why.
set shell=bash
let mapleader=","

set t_Co=256
set background=dark
"colorscheme solarized
colorscheme jellybeans
set statusline=%-(%f\ %y%r%)%=%30(%l,%c\ %b=%B\ %o\ %P%) laststatus=2

set number
set cul
set hlsearch

runtime macros/matchit.vim

if !exists("autocommands_loaded")
  " au BufLeave * :wa
  au BufRead,BufNewFile  *.html  set filetype=html
  au BufRead,BufNewFile  *.mas   set filetype=mason
  au FileType            perl    :compiler perl
  let autocommands_loaded = 1
endif

" ----------------------------------------------------------------------------
" Spacing
" ----------------------------------------------------------------------------
" Global settings for all files (but may be overridden in ftplugin in the future).
" http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean
set tabstop=2
set shiftwidth=2
set expandtab
set textwidth=80
" colorcolumn appears at textwidth+1
set colorcolumn=+1
set autoindent
" incrementalsearch
set is

au BufEnter *.js set sw=2 ts=2


" ----------------------------------------------------------------------------
" Prompt to mkdir if doesn't exist
" ----------------------------------------------------------------------------
augroup vimrc-auto-mkdir
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)
    if !isdirectory(a:dir)
          \   && (a:force
          \       || input("'" . a:dir . "' does not exist. Create? [y/N]") =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction
augroup END

" ----------------------------------------------------------------------------
" Create swp files outside of working dir
" ----------------------------------------------------------------------------
set backupdir=./.backup,.,/tmp

" ----------------------------------------------------------------------------
" Pathogen
" ----------------------------------------------------------------------------
call pathogen#infect()
"call pathogen#incubate()
call pathogen#helptags()

" ----------------------------------------------------------------------------
" Autosave macvim, remove trailing whitespace
" ----------------------------------------------------------------------------
autocmd BufLeave,FocusLost * silent! wall
autocmd BufWritePre * :%s/\s\+$//e

" ----------------------------------------------------------------------------
" first tab hit will complete as much as possible,
" the second tab hit will provide a list,
" the third and subsequent tabs will cycle through completion
" ----------------------------------------------------------------------------
set wildmode=longest,list,full
set wildmenu

" ----------------------------------------------------------------------------
" MacVim
" ----------------------------------------------------------------------------
if has("gui_running")
  set guioptions=-t
endif

" ----------------------------------------------------------------------------
" RUNNING TESTS
" ----------------------------------------------------------------------------
map <leader>s :call RunJasmineTests()<cr>
map <leader>t :call RunTestFile(0, 0)<cr>
map <leader>e :call RunTestFile(1, 0)<cr>
map <leader>T :call RunNearestTest(0)<cr>
map <leader>E :call RunNearestTest(1)<cr>
map <leader>a :call RunAllTests()<cr>
" map <leader>c :w\|:!script/features<cr>
map <leader>w :w<cr>

function! InTestFile()
  return match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
endfunction

function! RunTestFile(external, nearest)
    if InTestFile()
        call SetTestContext()
    elseif !exists("t:grb_test_file")
        return
    end

    if a:nearest
      let command_suffix = ":" . t:spec_line_number . " -b"
    else
      let command_suffix = ""
    end

    call RunTests(t:grb_test_file, command_suffix, a:external)
endfunction

function! RunNearestTest(external)
    call RunTestFile(a:external, 1)
endfunction

function! SetTestContext()
    " Set line number in case running nearest test
    let t:spec_line_number=line('.')
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunAllTests()
    :w
    " for some reason calling space-tdd-log in function adds hanging
    :silent execute ":!~/bin/space-tdd-log.sh"
    :silent exec ":!zeus rspec spec > ~/tmp/tdd.log &" | redraw!
endfunction

function! RunJasmineTests()
    :w
    call OutputWhiteSpace()
    exec ":!mocha" | redraw!
endfunction

function! RunTests(filename, command_suffix, external)
    " Write the file and run tests for the given filename
    :w
    let command = a:filename . a:command_suffix
    if a:external
      " for some reason calling space-tdd-log in function adds hanging
      :silent execute ":!~/bin/space-tdd-log.sh"
      :silent execute ":!~/dotfiles/bin/test " . command . "&> ~/tmp/tdd.log &" | redraw!
    else
      call OutputWhiteSpace()
      exec ":!~/dotfiles/bin/test " . command . " | tee ~/tmp/tdd.log"
    end
endfunction

function! OutputWhiteSpace()
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC KEY MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
" Clear the search buffer when hitting return
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()

" copy file name
:nmap cfn :let @* = expand("%")

" ----------------------------------------------------------------------------
" Control P
" ----------------------------------------------------------------------------
let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_custom_ignore = '.keep\|node_modules\|DS_Store\|git\|tmp/cache\|.swp'

" ----------------------------------------------------------------------------
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
" ----------------------------------------------------------------------------
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
      return "\<tab>"
    else
      return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Make a simple "search" text object http://vim.wikia.com/wiki/Copy_or_change_search_hit
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
    \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
omap s :normal vs<CR>
