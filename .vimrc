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
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
map <leader>a :call RunTests('')<cr>
map <leader>c :w\|:!script/features<cr>
map <leader>w :w\|:!script/features --profile wip<cr>

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    if match(a:filename, '\.feature$') != -1
        exec ":!script/features " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable("Gemfile")
            exec ":!bundle exec rspec --color " . a:filename
        else
            exec ":!rspec --color " . a:filename
        end
    end
endfunction

" ------------------------------------------------------------------------------
" Control P
" ------------------------------------------------------------------------------
let g:ctrlp_working_path_mode = 'r'
