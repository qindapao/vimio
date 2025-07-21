" autoload/vimio/todo.vim
" ---------------
" Contents:
" - vimio#todo#apply_highlight()
" - vimio#todo#clear_highlight()
" - vimio#todo#clear_todo_matches()
" - vimio#todo#collect_sorted_todo_items()
" - vimio#todo#find_max_braced_number()

" highlight default VimioTodoBug     ctermfg=DarkRed    guifg=#aa0000
" highlight default VimioTodoUrgent  ctermfg=Red        guifg=#ff4444
" highlight default VimioTodoLow     ctermfg=Green      guifg=#44aa44
" highlight default VimioTodoMedium  ctermfg=Blue       guifg=#005fff
" highlight default VimioTodoRegular ctermbg=Yellow     guibg=#999933
" Synchronize updates when switching themes
highlight default link VimioTodoBug     Error
highlight default link VimioTodoUrgent  WarningMsg
highlight default link VimioTodoLow     Identifier
highlight default link VimioTodoMedium  Type
highlight default link VimioTodoRegular Visual

function! vimio#todo#clear_todo_matches() abort
    if exists('b:todo_matches')
        unlet b:todo_matches
    endif
endfunction

function! vimio#todo#apply_highlight()
    if &filetype !=# 'qf'
        return
    endif

    call vimio#todo#clear_highlight()
    let b:todo_matches = []

    call add(b:todo_matches, matchadd('VimioTodoBug', '\[bug\]'))
    call add(b:todo_matches, matchadd('VimioTodoUrgent', '(!!!!)'))
    call add(b:todo_matches, matchadd('VimioTodoLow', '\(   !\|\(    \)\)'))
    call add(b:todo_matches, matchadd('VimioTodoMedium', '\(  !!\|\( !!!\)\)'))
    call add(b:todo_matches, matchadd('VimioTodoRegular', '^\f\+|\d\+| ·\{-}- \[.\{-}\]{\d\{4\}}(\([^)]*\)) \zs.*'))
endfunction

function! vimio#todo#clear_highlight()
    if exists('b:todo_matches')
        for id in b:todo_matches
            if type(id) == v:t_number && id >= 1
                silent! call matchdelete(id)
            endif
        endfor
        call vimio#todo#clear_todo_matches()
    endif
endfunction

function! vimio#todo#find_max_braced_number() abort
    " " Get all lines from current buffer
    let lines = getline(1, '$')

    " Collect all `{dddd}` matches
    let matches = []
    for line in lines
        let found = matchlist(line, '{\d\{4\}}')
        if !empty(found)
            call add(matches, found[0])
        endif
    endfor

    " Extract digits and convert to numbers
    let numbers = []
    for m in matches
        let numstr = matchstr(m, '\d\{4\}')
        call add(numbers, str2nr(numstr))
    endfor

    " Calculate next value
    let max_val = empty(numbers) ? 0 : max(numbers)
    let next_val = max_val + 1
    let formatted = printf('{%04d}', next_val)

    " Display in statusline
    echom 'Next Id: ' . formatted

    " Insert at cursor
    execute "normal! a" . formatted
endfunction

function! vimio#todo#collect_sorted_todo_items() abort
    " Priority mapping
    let priority_map = {
                \ '(!!!!)': 5,
                \ '( !!!)': 4,
                \ '(  !!)': 3,
                \ '(   !)': 2,
                \ '(    )': 1
                \ }

    " Get lines from buffer
    let lines = getline(1, '$')
    let results = []

    " Collect TODO lines
    for idx in range(len(lines))
        let line = lines[idx]
        " Filter out completed tasks
        if line =~? '^\s*[x\~]'
            continue
        endif

        let match = matchlist(line, '\v\{(\d{4})\}\((.{4})\)')
        if !empty(match)
            let prio_str = '(' . match[2] . ')'
            let prio_val = get(priority_map, prio_str, 0)
            " Quickfix and Locallist do not allow leading spaces to be displayed.
            call add(results, {'priority': prio_val, 'text': line, 'lnum': idx + 1})
        endif
    endfor

    call sort(results, {a,b -> b.priority - a.priority})

    " Build quickfix list from sorted results
    let qflist = map(results, {_, v ->
                \ { 'filename': bufname('%'),
                \   'lnum': v.lnum,
                \   'text': substitute(v.text, '^\s*', '\=repeat("·", len(submatch(0)))', '') }
                \ })

    " call setqflist(qflist, 'r')
    " copen
    call setloclist(0, qflist, 'r')
    lopen
    call vimio#todo#apply_highlight()
endfunction

