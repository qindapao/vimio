" autoload/vimio/scene.vim
" ---------------
" Set of scene judgment functions.
" Used to determine whether a character is suitable for use as a crosspoint, 
" connection point, etc., in a particular context.
"
" Contents:
" - vimio#scene#get_cross_chars(cross_point,all_chars)
" - vimio#scene#clear_cross_cache()

let s:empty_str_list = ['']

function! s:ConvertPointsToMap(raw) abort
    let result = {}
    for entry in a:raw
        let val = entry[0]
        let row = entry[1]
        let col = entry[2]

        if !has_key(g:vimio_config_draw_cross_chars, val)
            continue
        endif

        if !has_key(result, row)
            let result[row] = {}
        endif

        let result[row][col] = val
    endfor
    return result
endfunction

function! vimio#scene#get_cross_chars_native(cross_point, all_chars) abort

    let lib_path = vimio#utils#get_vimio_libs_path()
    if !filereadable(lib_path)
        " C lib file not exist，null need fallback
        return v:null
    endif

    " let t1 = reltime()
    let cross_json = json_encode(a:cross_point)
    let all_json = json_encode(a:all_chars)
    let mode = (g:vimio_vimiomono_super_slash_mode.index ==# 0)? '0' : '1'
    let input = cross_json . "\n" . all_json . "\n" . mode

    " let t2 = reltime()
    let result_json = libcall(lib_path, 'vimio_get_cross_chars', input)
    " let t3 = reltime()
    let json_str = json_decode(result_json)
    " let t4 = reltime()
    " let key_count = len(keys(json_str))

    " call vimio#debug#log("cnt: %d, encode time:%.2f, native time:%.2f, decode time:%.2f", 
    "             \ key_count,
    "             \ vimio#debug#time_ms(t1, t2),
    "             \ vimio#debug#time_ms(t2, t3),
    "             \ vimio#debug#time_ms(t3, t4))
    return json_str
endfunction

function! vimio#scene#get_cross_chars(cross_point, all_chars) abort
    " let t1 = reltime()
    let result = vimio#scene#get_cross_chars_native(a:cross_point, a:all_chars)
    " let t2 = reltime()

    if result !=# v:null
        for [key, center_char] in items(result)
            if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], center_char)
                let result[key] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][center_char]
            endif
        endfor

        " let t3 = reltime()
        " call vimio#debug#log(
        "             \ "take time:%.2f, style time:%.2f", 
        "             \ vimio#debug#time_ms(t1, t2), vimio#debug#time_ms(t2, t3))
        return result
    endif


    let result = {}
    " let t4 = reltime()
    for [key, cross_chars] in items(a:cross_point)
        " If there are characters in cross_chars that are not part of the cross
        " character set, exit directly without further judgment.
        let skip_this = 0
        for ch in cross_chars
            if !has_key(g:vimio_config_draw_cross_chars, ch)
                let skip_this = 1
                break
            endif
        endfor

        if skip_this
            continue
        endif

        " 这是更优雅的写法
        " let [row, col] = map(split(key, ','), 'str2nr(v:val)')
        " 这是更快的写法
        let comma = stridx(key, ',')
        let row = str2nr(strpart(key, 0, comma))
        let col = str2nr(strpart(key, comma + 1))

        "     col
        " row  x
        let left = (col>1) ? get(a:all_chars, row . ',' . (col-1), s:empty_str_list) : s:empty_str_list
        let right  = get(a:all_chars, row. ',' . (col+1), s:empty_str_list)
        let up = (row>1) ? get(a:all_chars, (row-1) . ',' . col, s:empty_str_list) : s:empty_str_list
        let down = get(a:all_chars, (row+1) . ',' . col, s:empty_str_list)
        if g:vimio_vimiomono_super_slash_mode.index != 0
            let diag_45   = (row > 1)             ? get(a:all_chars, (row - 1) . ',' . (col + 1), s:empty_str_list) : s:empty_str_list
            let diag_135  = (row > 1 && col > 1)  ? get(a:all_chars, (row - 1) . ',' . (col - 1), s:empty_str_list) : s:empty_str_list
            let diag_225  = (col > 1)             ? get(a:all_chars, (row + 1) . ',' . (col - 1), s:empty_str_list) : s:empty_str_list
            let diag_315  = get(a:all_chars, (row + 1) . ',' . (col + 1), s:empty_str_list)
        else
            let diag_45 = s:empty_str_list
            let diag_135 = s:empty_str_list
            let diag_225 = s:empty_str_list
            let diag_315 = s:empty_str_list
        endif

        let center_char = vimio#config#multi_cross_get_center_char(right, diag_45, up, diag_135, left, diag_225, down, diag_315, g:vimio_config_draw_char_funcs_map)
        if center_char !=# ''
            if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], center_char)
                let result[key] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][center_char]
            else
                let result[key] = center_char
            endif
        endif
    endfor

    " let t5 = reltime()
    " call vimio#debug#log(
    "             \ "new take time:%.2f old take time:%.2f", 
    "             \ vimio#debug#time_ms(t1, t3), vimio#debug#time_ms(t4, t5))

    return result
endfunction

function! s:GetSafeCell(cache, row, col) abort
    try
        return a:cache[a:row][a:col]
    catch
        return ''
    endtry
endfunction

function! vimio#scene#calculate_cross_points(points, cache_table, cross_style_table, cross_style_index, result_ref, ...) abort
    let is_row_cache_already = v:false
    if a:0 >= 1
        let is_row_cache_already = v:true
        let row_chars_cache = s:ConvertPointsToMap(a:1)
    else
        let row_chars_cache = {}
    endif

    for point in a:points
        " Skip non-crossing characters
        if !has_key(g:vimio_config_draw_cross_chars, point[0])
            continue
        endif

        " Cache line characters (current three lines above and below)
        for delta in [-1, 0, 1]
            let row_idx = point[1] + delta
            if row_idx < 1 || row_idx > line('$')
                continue
            endif

            if !is_row_cache_already
                if !has_key(row_chars_cache, row_idx)
                    let [row_chars_cache[row_idx], _] = vimio#utils#get_line_cells(row_idx, point[2])
                    call map(row_chars_cache[row_idx], {i, val -> has_key(g:vimio_config_draw_cross_chars, val) ? val : ''})
                    let tmp_dict = {}
                    call map(copy(row_chars_cache[row_idx]), {i, val -> extend(tmp_dict, {i + 1: val})})
                    let row_chars_cache[row_idx] = tmp_dict
                endif
            endif
        endfor

        " Retrieve characters from above, below, left, and right
        let up    = [s:GetSafeCell(row_chars_cache, point[1]-1, point[2])]
        let down  = [s:GetSafeCell(row_chars_cache, point[1]+1, point[2])]
        let left  = [s:GetSafeCell(row_chars_cache, point[1],   point[2]-1)]
        let right = [s:GetSafeCell(row_chars_cache, point[1],   point[2]+1)]

        if g:vimio_vimiomono_super_slash_mode.index != 0
            let diag_45 = [s:GetSafeCell(row_chars_cache, point[1]-1, point[2]+1)]
            let diag_135 = [s:GetSafeCell(row_chars_cache, point[1]-1, point[2]-1)]
            let diag_225 = [s:GetSafeCell(row_chars_cache, point[1]+1, point[2]-1)]
            let diag_315 = [s:GetSafeCell(row_chars_cache, point[1]+1, point[2]+1)]
        else
            let diag_45 = s:empty_str_list
            let diag_135 = s:empty_str_list
            let diag_225 = s:empty_str_list
            let diag_315 = s:empty_str_list
        endif

        let center_char = vimio#config#multi_cross_get_center_char(right, diag_45, up, diag_135, left, diag_225, down, diag_315, a:cache_table)
        if center_char !=# ''
            let result = has_key(a:cross_style_table[a:cross_style_index], center_char) ?
                        \ a:cross_style_table[a:cross_style_index][center_char] :
                        \ center_char
            call add(a:result_ref, [result, point[1], point[2]])
        endif
    endfor
endfunction

