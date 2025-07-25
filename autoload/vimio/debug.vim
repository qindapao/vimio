" autoload/vimio/debug.vim
" ---------------
" Contents:
" - vimio#debug#diff_pretty_lcs(obj1,obj2,indent_unit)
" - vimio#debug#get_logfile()
" - vimio#debug#get_timestamp_ms()
" - vimio#debug#log(fmt,...)
" - vimio#debug#log_obj(name,obj,...)
" - vimio#debug#pretty_print(name,obj,indent_unit,...)
" - vimio#debug#time_ms(t_start,t_end)
" - vimio#debug#toggle()

" :scriptnames Command to print all script IDs
function! s:describe_funcref(funcref) abort
    if type(a:funcref) != v:t_func
        return string(a:funcref)
    endif

    " Extract function name and SNR number
    let funcref_str = string(a:funcref)
    let fun_name = matchstr(funcref_str, "'\\zs<SNR>\\d\\+_\\w\\+\\ze'")
    let snr_id = matchstr(fun_name, '<SNR>\zs\d\+')

    " Find the corresponding file path in scriptnames
    let script_path = ''
    for line in split(execute('scriptnames'), "\n")
        if line =~ '^ *' . snr_id . ':'
            let script_path = substitute(line, '^ *\d\+: *', '', '')
            break
        endif
    endfor

    " Obtain the line number information of the verbose function
    let verbose_output = execute('verbose function ' . fun_name)
    let location = matchstr(verbose_output, '\(line\|行\) \d\+')

    return fun_name . ' (' . script_path . ' ' . location . ')'
endfunction

function! s:print_value(key, value, pad) abort
    if type(a:value) == v:t_func
        echom a:pad . string(a:key) . ': ' . s:describe_funcref(a:value)
    else
        echom a:pad . string(a:key) . ': ' . string(a:value)
    endif
endfunction


" :TODO: `echom` Unable to print original carriage return and line feed characters
"==============================================================================
" vimio#debug#pretty_print(name, obj, indent_unit [, title])
"
" Prints a nested Dict/List structure with:
"   • Top‐level:   name =>
"   • Dict entries:    key =>    (if value is Dict)
"                     key =:    (if value is List)
"                     key: val   (if primitive)
"   • List entries:    index =>  (if element is Dict)
"                     index =:  (if element is List)
"                     index: val (if primitive)
"   • Indentation: controlled by indent_unit
"   • Iterative implementation (no recursion)
"==============================================================================
function! vimio#debug#pretty_print(name, obj, indent_unit, ...) abort
    " Optional title
    if a:0 >= 1
        echom a:1
    endif

    " Top‐level
    echom a:name . ' =>'

    " Prepare initial frame for obj
    let stack = []

    if type(a:obj) == v:t_dict
        let keys = sort(keys(a:obj))
        call add(stack, {'type':'dict', 'val':a:obj, 'children':keys, 'idx':0, 'level':1})

    elseif type(a:obj) == v:t_list
        let indices = range(0, len(a:obj)-1)
        call add(stack, {'type':'list', 'val':a:obj, 'children':indices, 'idx':0, 'level':1})

    else
        " Primitive under the name
        echom repeat(' ', a:indent_unit) . ': ' . string(a:obj)
        return
    endif

    " Iterative loop
    while !empty(stack)
        let frame = remove(stack, -1)
        let lvl   = frame.level
        let pad   = repeat(' ', lvl * a:indent_unit)

        if frame.type ==# 'dict'
            if frame.idx < len(frame.children)
                let key      = frame.children[frame.idx]
                " This might be a function reference, so it should be named
                " with an uppercase letter at the beginning.
                let Value    = frame.val[key]
                " Prepare to resume this frame
                let next    = copy(frame)
                let next.idx = frame.idx + 1
                call add(stack, next)

                " Print and, if container, push child frame
                if type(Value) == v:t_dict
                    echom pad . string(key) . ' =>'
                    let child_keys = sort(keys(Value))
                    call add(stack, {
                                \ 'type'    :'dict',
                                \ 'val'     :Value,
                                \ 'children':child_keys,
                                \ 'idx'     :0,
                                \ 'level'   :lvl+1
                                \})
                elseif type(Value) == v:t_list
                    echom pad . string(key) . ' =:'
                    let child_idxs = range(0, len(Value)-1)
                    call add(stack, {
                                \ 'type'    :'list',
                                \ 'val'     :Value,
                                \ 'children':child_idxs,
                                \ 'idx'     :0,
                                \ 'level'   :lvl+1
                                \})
                else
                    call s:print_value(key, Value, pad)
                endif
            endif

        elseif frame.type ==# 'list'
            if frame.idx < len(frame.children)
                let i        = frame.children[frame.idx]
                let value    = frame.val[i]
                let next     = copy(frame)
                let next.idx = frame.idx + 1
                call add(stack, next)

                if type(value) == v:t_dict
                    echom pad . i . ' =>'
                    let child_keys = keys(value)
                    call add(stack, {
                                \ 'type'    :'dict',
                                \ 'val'     :value,
                                \ 'children':child_keys,
                                \ 'idx'     :0,
                                \ 'level'   :lvl+1
                                \})
                elseif type(value) == v:t_list
                    echom pad . i . ' =:'
                    let child_idxs = range(0, len(value)-1)
                    call add(stack, {
                                \ 'type'    :'list',
                                \ 'val'     :value,
                                \ 'children':child_idxs,
                                \ 'idx'     :0,
                                \ 'level'   :lvl+1
                                \})
                else
                    echom pad . i . ': ' . string(value)
                endif
            endif
        endif
    endwhile
endfunction

function! vimio#debug#diff_pretty_lcs(obj1, obj2, indent_unit) abort
    " Step 1: Pretty-print both objects
    let left_str = ''
    redir => left_str
    call vimio#debug#pretty_print('Left',  a:obj1, a:indent_unit)
    redir END

    let right_str = ''
    redir => right_str
    call vimio#debug#pretty_print('Right', a:obj2, a:indent_unit)
    redir END

    " Step 2: Split into lines
    let left_lines  = split(left_str,  "\n")
    let right_lines = split(right_str, "\n")
    let m = len(left_lines)
    let n = len(right_lines)

    " Step 3: Build LCS matrix
    let dp = []
    for i in range(0, m)
        call add(dp, repeat([0], n))
    endfor
    for i in range(m)
        for j in range(n)
            if left_lines[i] ==# right_lines[j]
                let dp[i][j] = (i>0 && j>0 ? dp[i-1][j-1] : 0) + 1
            else
                let dp[i][j] = max([
                            \ i>0 ? dp[i-1][j] : 0,
                            \ j>0 ? dp[i][j-1] : 0
                            \ ])
            endif
        endfor
    endfor

    " Step 4: Backtrack into rev_ops (reverse chronological)
    let rev_ops = []
    let i = m - 1
    let j = n - 1
    while i >= 0 || j >= 0
        if i>=0 && j>=0 && left_lines[i] ==# right_lines[j]
            call add(rev_ops, [' ', left_lines[i], right_lines[j]])
            let i -= 1 | let j -= 1
        elseif j>=0 && (i<0 || (i>=0 && dp[i][j-1] >= (i>0 ? dp[i-1][j] : 0)))
            call add(rev_ops, ['+', '', right_lines[j]])
            let j -= 1
        else
            call add(rev_ops, ['-', left_lines[i], ''])
            let i -= 1
        endif
    endwhile

    " Step 5: Reverse to chronological order
    let ops = reverse(rev_ops)

    " Step 6: Batch merge consecutive '-' followed '+' → '~'
    let new_ops = []
    let k = 0
    while k < len(ops)
        if ops[k][0] ==# '-'
            " Collect a segment of '-' running
            let minus_run = []
            while k < len(ops) && ops[k][0] ==# '-'
                call add(minus_run, ops[k])
                let k += 1
            endwhile

            " If followed by '+' for execution, synchronize collection.
            let plus_run = []
            if k < len(ops) && ops[k][0] ==# '+'
                while k < len(ops) && ops[k][0] ==# '+'
                    call add(plus_run, ops[k])
                    let k += 1
                endwhile
            endif

            " Pair and merge them in order into '~'.
            let cnt = min([len(minus_run), len(plus_run)])
            for idx in range(0, cnt - 1)
                call add(new_ops, ['~', minus_run[idx][1], plus_run[idx][2]])
            endfor

            " The remaining '-' lines
            for idx in range(cnt, len(minus_run) - 1)
                call add(new_ops, minus_run[idx])
            endfor

            " The remaining '+' lines
            for idx in range(cnt, len(plus_run) - 1)
                call add(new_ops, plus_run[idx])
            endfor

        else
            " Not starting with '-', directly copy
            call add(new_ops, ops[k])
            let k += 1
        endif
    endwhile
    let ops = new_ops

    " Step 7: Auto-determine column width
    let max_left  = 0
    let max_right = 0
    let rendered  = []

    for entry in ops
        let [op, L, R] = entry
        let max_left  = max([max_left, strlen(L)])
        let max_right = max([max_right, strlen(R)])
        call add(rendered, [op, L, R])
    endfor

    let col_width    = max([max_left, max_right])
    let header_width = col_width + 2
    let total_width  = header_width * 2 + 3
    let line_sep     = repeat('-', total_width)

    " Step 8: Render all ops with computed width
    echom line_sep
    echom printf('%-' . header_width . 's │ %-' . header_width . 's',
                \ 'Left Structure', 'Right Structure')
    echom line_sep

    for entry in rendered
        let [op, L, R] = entry
        if op ==# ' '
            echom printf('  %-' . col_width . 's │ %-' . col_width . 's', L, R)
        elseif op ==# '~'
            echohl WarningMsg
            echom printf('~ %-' . col_width . 's │ %-' . col_width . 's', L, R)
            echohl None
        elseif op ==# '-'
            echohl DiffDelete
            echom printf('- %-' . col_width . 's │ %-' . col_width . 's', L, '')
            echohl None
        elseif op ==# '+'
            echohl DiffAdd
            echom printf('+ %-' . col_width . 's │ %-' . col_width . 's', '', R)
            echohl None
        endif
    endfor
endfunction


function! vimio#debug#get_logfile() abort
    if has('win32') || has('win64')
        return expand('$TEMP') . '\\vimio_debug.log'
    else
        return '/tmp/vimio_debug.log'
    endif
endfunction

function! vimio#debug#get_timestamp_ms() abort
    " Current time (to the second)
    let t = reltime()
    let now = strftime("%Y-%m-%d %H:%M:%S")

    " For the millisecond part, use reltimefloat to obtain the high-precision 
    " second value of the current time.
    let ms = float2nr(reltimefloat(t) * 1000) % 1000

    " Composite timestamp: for example, [2025-07-10 09:15:42.027]
    return printf("[%s.%03d]", now, ms)
endfunction


function! vimio#debug#log(fmt, ...) abort
    if !exists('g:vimio_debug_mode') || !g:vimio_debug_mode
        return
    endif

    let logfile = vimio#debug#get_logfile()

    let args = []
    for i in range(1, a:0)
        call add(args, a:{i})
    endfor
    let arglist = [a:fmt] + args
    let formatted = call('printf', arglist)

    let timestamp = vimio#debug#get_timestamp_ms()

    call writefile([timestamp . ' ' . formatted], logfile, 'a')
endfunction

function! vimio#debug#log_obj(name, obj, ...) abort
    if !exists('g:vimio_debug_mode') || !g:vimio_debug_mode
        return
    endif

    let logfile = vimio#debug#get_logfile()

    if a:0 >= 1
        let indent = a:1
    else
        let indent = 2
    endif

    if a:0 >= 2
        let title = a:2
        call writefile([vimio#debug#get_timestamp_ms() . ' ' . title], logfile, 'a')
    endif

    if type(a:obj) == v:t_dict || type(a:obj) == v:t_list
        let out = ''
        redir => out
        silent call vimio#debug#pretty_print(a:name, a:obj, indent)
        redir END
        call writefile(split(out, "\n"), logfile, 'a')
    else
        let line = printf("[%s] %s: %s", vimio#debug#get_timestamp_ms(), a:name, string(a:obj))
        call writefile([line], logfile, 'a')
    endif
endfunction

function! vimio#debug#toggle() abort
    if !exists('g:vimio_debug_mode')
        let g:vimio_debug_mode = 1
    else
        let g:vimio_debug_mode = !g:vimio_debug_mode
    endif

    if g:vimio_debug_mode
        echohl WarningMsg
        echom "\U0001f7e2 Vimio debug mode is on"
    else
        echohl Question
        echom "⚪ Vimio debug mode is off"
    endif
    echohl None
endfunction

function! vimio#debug#time_ms(t_start, t_end) abort
    return reltimefloat(reltime(a:t_start, a:t_end)) * 1000
endfunction

