" autoload/vimio/shapes/box.vim
" ---------------
" Identify a box and adjust its size.
" Develop based on the following code.
"   https://github.com/nkh/P5-App-Asciio/blob/main/lib/App/Asciio/stripes/editable_box2.pm
"
" Contents:
" - vimio#shapes#box#new(element_definition)

let s:display = 0
let s:name    = 1
let s:left    = 2
let s:body    = 3
let s:right   = 4

let s:top             = 0
let s:title_separator = 1
let s:body_separator  = 2
let s:bottom          = 3
let s:fill_character  = 4



function! vimio#shapes#box#new(element_definition)
    let box = vimio#shapes#shapes#new(a:element_definition)

    for method in ['setup', 'set_box_type', 'get_box_frame_size_overhead',
                \ 'get_box_frame_elements', 'resize'
                \ ]
        let box[method] = function('s:' . method, box)
    endfor

    let box_type = get(a:element_definition, 'BOX_TYPE', deepcopy(g:vimio_config_shapes_box_type_default))

    call box.setup(
                \ a:element_definition.X,
                \ a:element_definition.Y,
                \ a:element_definition.TEXT_ONLY,
                \ a:element_definition.TITLE,
                \ box_type,
                \ a:element_definition.END_X,
                \ a:element_definition.END_Y
                \ )
    return box
endfunction

function! s:get_box_frame_size_overhead(box_type)
    let displayed_elements = filter(copy(a:box_type), 'v:val[s:display]')

    if a:box_type[s:body_separator][s:display]
        let left_widths = map(copy(displayed_elements), 'strdisplaywidth(v:val[s:left])')
        let right_widths = map(copy(displayed_elements), 'strdisplaywidth(v:val[s:right])')
        let extra_width = max([0] + left_widths) + max([0] + right_widths)
    else
        let extra_width = 0
    endif

    let extra_height = 0
    for idx in [s:top, s:title_separator, s:bottom]
        if a:box_type[idx][s:display]
            let extra_height += 1
        endif
    endfor

    return [extra_width, extra_height]
endfunction


function! s:get_box_frame_elements(box_type, width)
    let [box_top, box_left, box_right, box_bottom, title_separator, title_left, title_right] = repeat([''], 7)

    if a:box_type[s:top][s:display]
        let box_left_and_right_length = strdisplaywidth(a:box_type[s:top][s:left]) + strdisplaywidth(a:box_type[s:top][s:right])
        let box_top = a:box_type[s:top][s:left] 
                    \ . repeat(a:box_type[s:top][s:body], a:width-box_left_and_right_length)
                    \ . a:box_type[s:top][s:right] 
                    \ . "\n"
    endif

    if a:box_type[s:body_separator][s:display]
        let title_left = a:box_type[s:title_separator][s:left]
    endif

    if a:box_type[s:body_separator][s:display]
        let title_right = a:box_type[s:title_separator][s:right]
    endif

    if a:box_type[s:title_separator][s:display]
        let title_left_and_right_length = strdisplaywidth(title_left) + strdisplaywidth(title_right)

        let title_separator_body = a:box_type[s:title_separator][s:body]

        if title_separator_body ==# ''
            let title_separator_body = ' '
        endif

        let title_separator = title_left
                    \ . repeat(title_separator_body, a:width - title_left_and_right_length)
                    \ . title_right 
                    \ . "\n"
    endif

    if a:box_type[s:body_separator][s:display]
        let box_left = a:box_type[s:body_separator][s:left]
    endif

    if a:box_type[s:body_separator][s:display]
        let box_right = a:box_type[s:body_separator][s:right]
    endif

    if a:box_type[s:bottom][s:display]
        let box_left_and_right_length = strdisplaywidth(a:box_type[s:bottom][s:left]) + strdisplaywidth(a:box_type[s:bottom][s:right])
        let box_bottom = a:box_type[s:bottom][s:left] 
                    \ . repeat(a:box_type[s:bottom][s:body], a:width - box_left_and_right_length)
                    \ . a:box_type[s:bottom][s:right]
    endif

    return [box_top, box_left, box_right, box_bottom, title_separator, title_left, title_right]
endfunction


function! s:setup(X, Y, text_only, title, box_type, end_x, end_y) dict abort
    let fill_char = ' '
    if a:box_type[s:fill_character][s:body] !=# ''
        let fill_char = a:box_type[s:fill_character][s:body]
    endif
    let text_width = 0
    let lines = []

    " echom "test_only: " . a:text_only

    for line in split(a:text_only, "\n")
        let text_width = max([text_width, strdisplaywidth(line)])
        call add(lines, line)
    endfor

    let title_width = 0
    let title_lines = []
    let title_text = a:title

    for title_line in split(title_text, "\n")
        let title_width = max([title_width, strdisplaywidth(title_line)])
        call add(title_lines, title_line)
    endfor

    let [extra_width, extra_height] = self.get_box_frame_size_overhead(a:box_type)

    let text_width = max([text_width, title_width])
    
    let box_min_x = max([text_width + extra_width, title_width + extra_width])
    let end_x = max([a:end_x, box_min_x])

    " echom "end_x: " . a:end_x . ';text_width: ' . text_width . ";extra_width: " . extra_width . ";title_width: " . title_width . ';'

    let box_min_y = len(lines) + extra_height + len(title_lines)
    let end_y = max([a:end_y, box_min_y])

    let [box_top, box_left, box_right, box_bottom, title_separator, title_left, title_right] = self.get_box_frame_elements(a:box_type, end_x)

    let text = box_top

    for title_line in title_lines
        let pading = end_x - strdisplaywidth(title_left . title_line . title_right)
        let left_pading =  float2nr(pading / 2)
        let right_pading = pading - left_pading

        let text = text . title_left . repeat(fill_char, left_pading) . title_line . repeat(fill_char, right_pading) . title_right . "\n"
    endfor

    let text = text . title_separator

    for line in lines
        let text = text . box_left . line . repeat(fill_char, end_x - (strdisplaywidth(line) + extra_width)) . box_right . "\n"
    endfor

    let fill_count = end_y - (len(lines) + extra_height + len(title_lines))
    for _ in range(fill_count)
        let text = text . box_left . repeat(fill_char, end_x - extra_width) . box_right . "\n"
    endfor
    
    let text = text . box_bottom

    let [text_begin_x, text_begin_y, title_separator_exist] = [0, 0, 0]
    if box_top !=# ''
        let text_begin_y += 1
    endif

    let text_begin_x = strdisplaywidth(box_left)
    if title_separator !=# ''
        let title_separator_exist = 1
    endif
    
    " g:vimio_shape_name_config_map -> 'NAME'
    call self.set({
                \ 'NAME': 'box',
                \ 'X': a:X,
                \ 'Y': a:Y,
                \ 'TEXT': text,
                \ 'TITLE': title_text,
                \ 'WIDTH': end_x,
                \ 'HEIGH': end_y,
                \ 'MIN_WIDTH': box_min_x,
                \ 'MIN_HEIGH': box_min_y,
                \ 'TEXT_ONLY': a:text_only,
                \ 'TEXT_BEGIN_X': text_begin_x,
                \ 'TEXT_BEGIN_Y': text_begin_y,
                \ 'TITLE_SEPARATOR_EXIST': title_separator_exist,
                \ 'BOX_TYPE': a:box_type,
                \ 'EXTENTS': [0, 0, end_x, end_y],
                \ 'STRIPES': [{
                \   'X_OFFSET': 0,
                \   'Y_OFFSET': 0,
                \   'WIDTH': end_x,
                \   'HEIGH': end_y,
                \   'TEXT': text
                \   }],
                \})
endfunction

function! s:set_box_type(box_type) dict abort
    call self.setup(
                \ self.X,
                \ self.Y,
                \ self.TEXT_ONLY,
                \ self.TITLE,
                \ a:box_type,
                \ self.WIDTH,
                \ self.HEIGH
                \)
endfunction

function! s:resize(new_x, new_y) dict abort
    call self.setup(
                \ self.X,
                \ self.Y,
                \ self.TEXT_ONLY,
                \ self.TITLE,
                \ self.BOX_TYPE,
                \ a:new_x,
                \ a:new_y
                \)
    return [0, 0, self.WIDTH, self.HEIGH]
endfunction


