" autoload/vimio/shapes/shapes.vim
" ---------------
" Identify a box and adjust its size.
"
" Develop based on the following code.
" https://github.com/nkh/P5-App-Asciio/blob/main/lib/App/Asciio/stripes/stripes.pm
"
" Contents:
" - vimio#popup#update_block()
" - vimio#popup#close_block()

" :TODO: 变大变小的时候，顶点字符保持，每条边的字符保持。
" 如果盒子有标题栏，那么标题栏的横线也要一起边长和变短
" 支持收缩盒子功能，就是按照盒子内部的文字的矩形大小自动调整成最小盒子包裹。
" 文字的位置不变。
" 也可以支持盒子展开功能，比如，往外或者外内扩张或者收缩一个单位
"
" 但是需先支持删除后补齐交叉点字符的功能，因为重新调整一个图形的大小，相当于
" 先把这个图形删除掉，然后再按照某个点作为起点重新生成一个。并且要指定是否有标题
" 栏

let s:shapes_template = {
            \ 'ANCHOR': 'topleft',
            \ 'EXTENTS': [-1, -1, -1, -1],
            \ 'WIDTH': 0,
            \ 'HEIGH': 0,
            \ 'STRIPES': [],
            \ }

function! vimio#shapes#shapes#new(element_definition) abort
    let stripes = []
    let [total_width, total_height] = [0, 0]
    let [min_x, min_y, max_x, max_y] = [1, 1, 1, 1]
    
    if has_key(a:element_definition, 'STRIPES')
        for stripe in a:element_definition['STRIPES']
            let text = stripe.TEXT
            let text_list = split(text, "\n")
            let width = max(map(copy(text_list), 'strdisplaywidth(v:val)'))
            let height = len(text_list)
            call add(stripes, {
                        \ 'TEXT': text,
                        \ 'X_OFFSET': stripe.X_OFFSET,
                        \ 'Y_OFFSET': stripe.Y_OFFSET,
                        \ 'WIDTH': width,
                        \ 'HEIGH': height,
                        \ })
            let total_width = max([total_width, stripe.X_OFFSET+width])
            let total_height = max([total_height, stripe.Y_OFFSET+height])
            let min_x = min([min_x, stripe.X_OFFSET])
            let max_x = max([max_x, stripe.X_OFFSET+width])
            let min_y = min([min_y, stripe.Y_OFFSET])
            let max_y = max([max_y, stripe.Y_OFFSET+height])
        endfor
    endif

    let shape = deepcopy(s:shapes_template)
    call extend(shape, {
                \ 'EXTENTS': [min_x, max_x, min_y, max_y],
                \ 'STRIPES': stripes,
                \ 'WIDTH': total_width,
                \ 'HEIGH': total_height,
                \ })
    for method in ['set', 'get_stripes', 'get_size', 'get_extents', 'resize',
                \]
        let shape[method] = function('s:' . method, shape)
    endfor

    return shape
endfunction

function! s:set(key_values) dict abort
    for [key, value] in items(a:key_values)
        let self[key] = value
    endfor
endfunction

function! s:get_stripes() dict abort
    return self.STRIPES
endfunction

function! s:get_size() dict abort
    return [self.WIDTH, self.HEIGH]
endfunction

function! s:get_extents() dict abort
    return self.EXTENTS
endfunction

" The resize design needs to be implemented from four directions.
function! s:resize()
endfunction

