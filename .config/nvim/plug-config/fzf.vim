"noremap <silent> <leader>b :FzfBuffers<CR>
"noremap <silent> <leader>c :FzfCommits<CR>
"noremap <silent> <leader>f :FzfRg<CR>
"noremap <silent> <leader>g :FzfGFiles<CR>
"noremap <silent> <leader>h :FzfHistory<CR>
"noremap <silent> <leader>z :FzfFiles<CR>

" Calls to Fzf should be prefixed with 'Fzf' to ensure there are no clashes
" with other plugins.
"let g:fzf_command_prefix = 'Fzf'

" Jump to existing window, if available.
"let g:fzf_buffers_jump = 1

" Search from the top.
"let $FZF_DEFAULT_OPTS = '--layout=reverse --inline-info'

" Explicitly set keys to open files in splits.
" These are the defaults.
"let g:fzf_action = {
"			\ 'ctrl-t': 'tab split',
"			\ 'ctrl-x': 'split',
"			\ 'ctrl-v': 'vsplit' }

" Set colors to match the colorscheme.
"let g:fzf_colors = {
"			\ 'fg':      ['fg', 'Normal'],
"			\ 'bg':      ['bg', 'Normal'],
"			\ 'hl':      ['fg', 'Comment'],
"			\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"			\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"			\ 'hl+':     ['fg', 'Statement'],
"			\ 'info':    ['fg', 'PreProc'],
"			\ 'border':  ['fg', 'Ignore'],
"			\ 'prompt':  ['fg', 'Conditional'],
"			\ 'pointer': ['fg', 'Exception'],
"			\ 'marker':  ['fg', 'Keyword'],
"			\ 'spinner': ['fg', 'Label'],
"			\ 'header':  ['fg', 'Comment'] }

" Set the layout of the window.
"let g:fzf_layout = {
"			\ 'up':'~90%',
"			\ 'window': {
"			\ 'width': 0.8,
"			\ 'height': 0.3,
"			\ 'yoffset':0.5,
"			\ 'xoffset': 0.5,
"			\ 'highlight': 'Todo',
"			\ 'border': 'sharp' } }








" -------------------------------------------------------------------------------------------------
" Navigation, search and fuzzy finding settings
" -------------------------------------------------------------------------------------------------

nnoremap <silent> <leader><space> :Files<CR>
  nnoremap <silent> <leader>a :Buffers<CR>
  nnoremap <silent> <leader>A :Windows<CR>
  nnoremap <silent> <leader>; :BLines<CR>
  nnoremap <silent> <leader>o :BTags<CR>
  nnoremap <silent> <leader>O :Tags<CR>
  nnoremap <silent> <leader>? :History<CR>
  nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>
  nnoremap <silent> <leader>. :AgIn 

  nnoremap <silent> K :call SearchWordWithAg()<CR>
  vnoremap <silent> K :call SearchVisualSelectionWithAg()<CR>
  nnoremap <silent> <leader>gl :Commits<CR>
  nnoremap <silent> <leader>ga :BCommits<CR>
  nnoremap <silent> <leader>ft :Filetypes<CR>

  imap <C-x><C-f> <plug>(fzf-complete-file-ag)
  imap <C-x><C-l> <plug>(fzf-complete-line)

  function! SearchWordWithAg()
    execute 'Ag' expand('<cword>')
  endfunction

  function! SearchVisualSelectionWithAg() range
    let old_reg = getreg('"')
    let old_regtype = getregtype('"')
    let old_clipboard = &clipboard
    set clipboard&
    normal! ""gvy
    let selection = getreg('"')
    call setreg('"', old_reg, old_regtype)
    let &clipboard = old_clipboard
    execute 'Ag' selection
  endfunction

  function! SearchWithAgInDirectory(...)
    call fzf#vim#ag(join(a:000[1:], ' '), extend({'dir': a:1}, g:fzf#vim#default_layout))
  endfunction
  command! -nargs=+ -complete=dir AgIn call SearchWithAgInDirectory(<f-args>)


let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }
let $FZF_DEFAULT_OPTS="--reverse " " top to bottom

" use rg by default
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!{.git/*,web/*}"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!{.git/*,web/*}" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

" floating fzf window with borders
function! CreateCenteredFloatingWindow()
    let width = float2nr(&columns * 0.8)
    let height = float2nr(&lines * 0.9)
    "let width = min([&columns - 4, max([80, &columns - 20])])
    "let height = min([&lines - 4, max([20, &lines - 10])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    au BufWipeout <buffer> exe 'bw '.s:buf
endfunction

" Files + devicons + floating fzf
function! Fzf_dev()
  let l:fzf_files_options = '--preview "bat --line-range :'.&lines.' --theme="OneHalfDark" --style=numbers,changes --color always {2..-1}"'
  function! s:files()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return s:prepend_icon(l:files)
  endfunction

  function! s:prepend_icon(candidates)
    let l:result = []
    for l:candidate in a:candidates
      let l:filename = fnamemodify(l:candidate, ':p:t')
      let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
      call add(l:result, printf('%s %s', l:icon, l:candidate))
    endfor

    return l:result
  endfunction

  function! s:edit_file(item)
    let l:pos = stridx(a:item, ' ')
    let l:file_path = a:item[pos+1:-1]
    execute 'silent e' l:file_path
  endfunction

  call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink':   function('s:edit_file'),
        \ 'options': '-m --reverse ' . l:fzf_files_options,
        \ 'down':    '40%',
        \ 'window': 'call CreateCenteredFloatingWindow()'})

endfunction

fun! s:fzf_root()
	let path = finddir(".git", expand("%:p:h").";")
	return fnamemodify(substitute(path, ".git", "", ""), ":p:h")
endfun

nnoremap <silent> <Leader>ff :exe 'Files ' . <SID>fzf_root()<CR>

nnoremap <silent> <leader>f :call Fzf_dev()<CR>
