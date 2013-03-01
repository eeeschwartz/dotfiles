set nocompatible

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

if !exists("autocommands_loaded")
  " au BufLeave * :wa
  au BufRead,BufNewFile  *.html  set filetype=mason
  au BufRead,BufNewFile  *.mas   set filetype=mason
  au FileType            perl    :compiler perl
  let autocommands_loaded = 1
endif

" ------------------------------------------------------------------------------
" Spacing
" ------------------------------------------------------------------------------
" Global settings for all files (but may be overridden in ftplugin in the future).
" http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean
set tabstop=2
set shiftwidth=2
set expandtab
set textwidth=80
" colorcolumn appears at textwidth+1
set colorcolumn=+1
set autoindent

au BufEnter *.js set sw=2 ts=2

" ------------------------------------------------------------------------------
" Create swp files outside of working dir
" ------------------------------------------------------------------------------
set backupdir=./.backup,.,/tmp

" ------------------------------------------------------------------------------
" Pathogen
" ------------------------------------------------------------------------------
call pathogen#infect()
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" ------------------------------------------------------------------------------
" Autosave macvim, remove trailing whitespace
" ------------------------------------------------------------------------------
autocmd BufLeave,FocusLost * silent! wall
autocmd BufWritePre * :%s/\s\+$//e

" ------------------------------------------------------------------------------
" first tab hit will complete as much as possible,
" the second tab hit will provide a list,
" the third and subsequent tabs will cycle through completion
" ------------------------------------------------------------------------------
set wildmode=longest,list,full
set wildmenu

" ------------------------------------------------------------------------------
" Coffee script
" ------------------------------------------------------------------------------
au BufWritePost *.coffee silent CoffeeMake!


" ------------------------------------------------------------------------------
" MacVim
" ------------------------------------------------------------------------------
if has("gui_running")
  set guioptions=-t
endif

" ------------------------------------------------------------------------------
" RUNNING TESTS
" ------------------------------------------------------------------------------
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
    :silent exec ":!bundle exec rspec spec --tag chicago &> ~/tmp/tdd.log &" | redraw!
endfunction

function! RunTests(filename, command_suffix, external)
    " Write the file and run tests for the given filename
    :w
    let command = a:filename . a:command_suffix
    if a:external
      " for some reason calling space-tdd-log in function adds hanging
      :silent execute ":!~/bin/space-tdd-log.sh"
      :silent execute ":!script/test " . command . "&> ~/tmp/tdd.log &" | redraw!
    else
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
      exec ":!script/test " . command . " | tee ~/tmp/tdd.log"
    end
endfunction

" ------------------------------------------------------------------------------
" Misc
" ------------------------------------------------------------------------------
" Clear the search buffer when hitting return
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()

" ------------------------------------------------------------------------------
" Control P
" ------------------------------------------------------------------------------
let g:ctrlp_working_path_mode = 'r'

" ------------------------------------------------------------------------------
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
" ------------------------------------------------------------------------------
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
