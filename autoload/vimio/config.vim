" autoload/vimio/config.vim
" ----------------
" Global configuration of the plugin and character set definition.
" Contains all variables initialized with g:vimio_ prefix, such as drawing 
" characters, cross characters, etc.
"
" Contents:
" - g:vimio_config_visual_block_popup_types
" - g:vimio_config_draw_cross_chars
" - g:vimio_config_draw_unicode_cross_chars
" - g:vimio_config_draw_index_map_left
" - g:vimio_config_draw_index_map_right
" - g:vimio_config_draw_index_map_up
" - g:vimio_config_draw_index_map_down
" - g:vimio_config_draw_normal_char_funcs_map
" - g:vimio_config_draw_line_styles
" - g:vimio_config_draw_cross_styles
" - g:vimio_config_arrow_chars_map

let g:vimio_config_visual_block_popup_types = ['cover', 'overlay']
let g:vimio_config_draw_cross_chars = {
    \ '-': 1, '|': 1, '+': 1, '.': 1, "'": 1, '^': 1, 'v': 1, '<': 1, '>': 1,
    \ '─': 1, '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╮': 1, '╯': 1, '╰': 1,
    \ '━': 1, '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┓': 1, '┛': 1, '┗': 1,
    \ '═': 1, '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╗': 1, '╝': 1, '╚': 1,
    \ '╫': 1, '╪': 1, '╨': 1, '╧': 1, '╥': 1, '╤': 1, '╢': 1, '╡': 1, '╟': 1, '╞': 1, '╜': 1,
    \ '╛': 1, '╙': 1, '╘': 1, '╖': 1, '╕': 1, '╓': 1, '╒': 1,
    \ '┍': 1, '┎': 1, '┑': 1, '┒': 1, '┕': 1, '┖': 1, '┙': 1, '┚': 1,
    \ '┝': 1, '┞': 1, '┟': 1, '┠': 1, '┡': 1, '┢': 1,
    \ '┥': 1, '┦': 1, '┧': 1, '┨': 1, '┩': 1, '┪': 1,
    \ '┭': 1, '┮': 1, '┯': 1, '┰': 1, '┱': 1, '┲': 1,
    \ '┵': 1, '┶': 1, '┷': 1, '┸': 1, '┹': 1, '┺': 1,
    \ '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1,
    \ '╄': 1, '╅': 1, '╆': 1, '╇': 1, '╈': 1, '╉': 1, '╊': 1,
    \ '┌': 1, '┐': 1, '└': 1, '┘': 1, '┅': 1, '┄': 1, '┆': 1, '┇': 1, ')': 1, '❫': 1, '⟫': 1, '▲': 1, '▼': 1, '◀': 1, '▶': 1,
    \ '△': 1, '▽': 1, '◁': 1, '▷': 1
    \ }
let g:vimio_config_draw_unicode_cross_chars = [
    \ {
    \ '─': 1, '┼': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╰': 1, '╫': 1, '╨': 1, '╥': 1, '╟': 1, '╙': 1, '╓': 1, '┎': 1, '┖': 1, '┞': 1, '┟': 1, '┠': 1, '┭': 1, '┰': 1, '┱': 1, '┵': 1, '┸': 1, '┹': 1, '┽': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1, '╅': 1, '╉': 1, '┌': 1, '└': 1, '┄': 1, '<': 1
    \ },
    \ {
    \ '═': 1, '╬': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╚': 1, '╪': 1, '╧': 1, '╤': 1, '╞': 1, '╘': 1, '╒': 1, '◁': 1
    \ },
    \ {
    \ '━': 1, '╋': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┗': 1, '┍': 1, '┕': 1, '┝': 1, '┡': 1, '┢': 1, '┮': 1, '┯': 1, '┲': 1, '┶': 1, '┷': 1, '┺': 1, '┾': 1, '┿': 1, '╄': 1, '╆': 1, '╇': 1, '╈': 1, '╊': 1, '┅': 1, '◀': 1
    \ },
    \ {
    \ '─': 1, '┼': 1, '┤': 1, '┬': 1, '┴': 1, '╮': 1, '╯': 1, '╫': 1, '╨': 1, '╥': 1, '╢': 1, '╜': 1, '╖': 1, '┒': 1, '┚': 1, '┦': 1, '┧': 1, '┨': 1, '┮': 1, '┰': 1, '┲': 1, '┶': 1, '┸': 1, '┺': 1, '┾': 1, '╀': 1, '╁': 1, '╂': 1, '╄': 1, '╆': 1, '╊': 1, '┐': 1, '┘': 1, '┄': 1, '>': 1
    \ },
    \ {
    \ '═': 1, '╬': 1, '╣': 1, '╦': 1, '╩': 1, '╗': 1, '╝': 1, '╪': 1, '╧': 1, '╤': 1, '╡': 1, '╛': 1, '╕': 1, '▷': 1 
    \ },
    \ {
    \ '━': 1, '╋': 1, '┫': 1, '┳': 1, '┻': 1, '┓': 1, '┛': 1, '┑': 1, '┙': 1, '┥': 1, '┩': 1, '┪': 1, '┭': 1, '┯': 1, '┱': 1, '┵': 1, '┷': 1, '┹': 1, '┽': 1, '┿': 1, '╃': 1, '╅': 1, '╇': 1, '╈': 1, '╉': 1, '┅': 1, '▶': 1
    \ },
    \ {
    \ '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '╭': 1, '╮': 1, '╪': 1, '╤': 1, '╡': 1, '╞': 1, '╕': 1, '╒': 1, '┍': 1, '┑': 1, '┝': 1, '┞': 1, '┡': 1, '┥': 1, '┦': 1, '┩': 1, '┭': 1, '┮': 1, '┯': 1, '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╃': 1, '╄': 1, '╇': 1, '┌': 1, '┐': 1, '┆': 1, ')': 1, '^': 1
    \ },
    \ {
    \ '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╔': 1, '╗': 1, '╫': 1, '╥': 1, '╢': 1, '╟': 1, '╖': 1, '╓': 1, '⟫': 1, '△': 1
    \ },
    \ {
    \ '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┏': 1, '┓': 1, '┎': 1, '┒': 1, '┟': 1, '┠': 1, '┢': 1, '┧': 1, '┨': 1, '┪': 1, '┰': 1, '┱': 1, '┲': 1, '╁': 1, '╂': 1, '╅': 1, '╆': 1, '╈': 1, '╉': 1, '╊': 1, '┇': 1, '❫': 1, '▲': 1
    \ },
    \ {
    \ '│': 1, '┼': 1, '┤': 1, '├': 1, '┴': 1, '╯': 1, '╰': 1, '╪': 1, '╧': 1, '╡': 1, '╞': 1, '╛': 1, '╘': 1, '┕': 1, '┙': 1, '┝': 1, '┟': 1, '┢': 1, '┥': 1, '┧': 1, '┪': 1, '┵': 1, '┶': 1, '┷': 1, '┽': 1, '┾': 1, '┿': 1, '╁': 1, '╅': 1, '╆': 1, '╈': 1, '└': 1, '┘': 1, '┆': 1, ')': 1, 'v': 1
    \ },
    \ {
    \ '║': 1, '╬': 1, '╣': 1, '╠': 1, '╩': 1, '╝': 1, '╚': 1, '╫': 1, '╨': 1, '╢': 1, '╟': 1, '╜': 1, '╙': 1, '⟫': 1, '▽': 1
    \ },
    \ {
    \ '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┻': 1, '┛': 1, '┗': 1, '┖': 1, '┚': 1, '┞': 1, '┠': 1, '┡': 1, '┦': 1, '┨': 1, '┩': 1, '┸': 1, '┹': 1, '┺': 1, '╀': 1, '╂': 1, '╃': 1, '╄': 1, '╇': 1, '╉': 1, '╊': 1, '┇': 1, '❫': 1, '▼': 1
    \ }
    \ ]

let s:vimio_config_draw_index_left_thin    = 0
let s:vimio_config_draw_index_left_double  = 1
let s:vimio_config_draw_index_left_bold    = 2
let s:vimio_config_draw_index_right_thin   = 3
let s:vimio_config_draw_index_right_double = 4
let s:vimio_config_draw_index_right_bold   = 5
let s:vimio_config_draw_index_up_thin      = 6
let s:vimio_config_draw_index_up_double    = 7
let s:vimio_config_draw_index_up_bold      = 8
let s:vimio_config_draw_index_down_thin    = 9
let s:vimio_config_draw_index_down_double  = 10
let s:vimio_config_draw_index_down_bold    = 11

let g:vimio_config_draw_index_map_left = {s:vimio_config_draw_index_left_thin: 1, s:vimio_config_draw_index_left_double: 1, s:vimio_config_draw_index_left_bold: 1}
let g:vimio_config_draw_index_map_right = {s:vimio_config_draw_index_right_thin: 1, s:vimio_config_draw_index_right_double: 1, s:vimio_config_draw_index_right_bold: 1}
let g:vimio_config_draw_index_map_up = {s:vimio_config_draw_index_up_thin: 1, s:vimio_config_draw_index_up_double: 1, s:vimio_config_draw_index_up_bold: 1}
let g:vimio_config_draw_index_map_down = {s:vimio_config_draw_index_down_thin: 1, s:vimio_config_draw_index_down_double: 1, s:vimio_config_draw_index_down_bold: 1}

" Arranging them in order can reduce logical judgment. Because calculations are done sequentially
" 1. First are cross,
" 2. then are corner missing
" 3. and finally are two corners missing.
" Therefore, the order of functions in the array cannot be disrupted
let g:vimio_config_draw_normal_char_funcs_map = [
    \ ['+',  "vimio#scene#cross",     []                                  ],
    \ ['.',  "vimio#scene#dot",       []                                  ],
    \ ["'", "vimio#scene#apostrophe", []                                  ],
    \ ['┽' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┾' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┿' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╀' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╁' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╂' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╃' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╄' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╅' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╆' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╇' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╈' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╉' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╊' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╫' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_double , s:vimio_config_draw_index_down_double ]],
    \ ['╪' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┼' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin   , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╋' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold   , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['╬' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_double , s:vimio_config_draw_index_down_double ]],
    \ ['┵' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┶' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┷' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┸' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold     ]],
    \ ['┹' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold     ]],
    \ ['┺' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold     ]],
    \ ['┭' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┮' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┯' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┰' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┱' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┲' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┥' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┦' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┧' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┨' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┩' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┪' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┝' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┞' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┟' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┠' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┡' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┢' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_bold   ]],
    \ ['╨' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_double   ]],
    \ ['╧' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_thin     ]],
    \ ['╥' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_double ]],
    \ ['╤' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_down_thin   ]],
    \ ['╢' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_double    , s:vimio_config_draw_index_down_double ]],
    \ ['╡' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['╟' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_double    , s:vimio_config_draw_index_down_double ]],
    \ ['╞' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┤' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['├' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin      , s:vimio_config_draw_index_down_thin   ]],
    \ ['┬' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┴' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┫' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┣' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold      , s:vimio_config_draw_index_down_bold   ]],
    \ ['┳' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┻' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold     ]],
    \ ['╣' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_up_double    , s:vimio_config_draw_index_down_double ]],
    \ ['╠' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_double    , s:vimio_config_draw_index_down_double ]],
    \ ['╦' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_down_double ]],
    \ ['╩' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_double   ]],
    \ ['╜' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_double   ]],
    \ ['╛' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_up_thin     ]],
    \ ['╙' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_double   ]],
    \ ['╘' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_thin     ]],
    \ ['╖' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_down_double ]],
    \ ['╕' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_down_thin   ]],
    \ ['╓' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_double ]],
    \ ['╒' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_down_thin   ]],
    \ ['┍' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_thin   ]],
    \ ['┎' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┑' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_down_thin   ]],
    \ ['┒' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_down_bold   ]],
    \ ['┕' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┖' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_bold     ]],
    \ ['┙' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_thin     ]],
    \ ['┚' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_bold     ]],
    \ ['╭' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_down_thin   ]],
    \ ['╮' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_down_thin   ]],
    \ ['╯' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_thin    , s:vimio_config_draw_index_up_thin     ]],
    \ ['╰' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_thin   , s:vimio_config_draw_index_up_thin     ]],
    \ ['┏' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_down_bold   ]],
    \ ['┓' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_down_bold   ]],
    \ ['┛' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_bold    , s:vimio_config_draw_index_up_bold     ]],
    \ ['┗' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_bold   , s:vimio_config_draw_index_up_bold     ]],
    \ ['╔' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_down_double ]],
    \ ['╗' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_down_double ]],
    \ ['╝' , "vimio#scene#unicode" , [s:vimio_config_draw_index_left_double  , s:vimio_config_draw_index_up_double   ]],
    \ ['╚' , "vimio#scene#unicode" , [s:vimio_config_draw_index_right_double , s:vimio_config_draw_index_up_double   ]]
    \ ]

let g:vimio_config_draw_line_styles = [['-', '|'], ['─', '│'], ['━', '┃'], ['═', '║'], ['┅', '┇'], ['┄', '┆']]
let g:vimio_config_draw_diagonal_line_styles = [['/', '\'], ['/', '\'], ['/', '\'], ['/', '\'], ['/', '\'], ['/', '\']]
" The index here correspond one-to-one with those above.
let g:vimio_config_line_and_box_corner_chars = {
            \ 'up-left': ['.', '╮', '┓', '╗', '┓', '╮'],
            \ 'up-right': ['.', '╭', '┏', '╔', '┏', '╭'],
            \ 'down-left': ["'", '╯', '┛', '╝', '┛', '╯'],
            \ 'down-right': ["'", '╰', '┗', '╚', '┗', '╰'],
            \ 'left-up': ["'", '╰', '┗', '╚', '┗', '╰'],
            \ 'left-down': ['.', '╭', '┏', '╔', '┏', '╭'],
            \ 'right-up': ["'", '╯', '┛', '╝', '┛', '╯'],
            \ 'right-down': ['.', '╮', '┓', '╗', '┓', '╮'],
            \}

" The corner needs to be drawn first in the case of a straight line.
" s: The starting point is a straight line.
" d: The starting point is a slant line.
let g:vimio_config_diagonal_line_corner_chars = {
            \ 'up-left-s': ["'", "'", "'", "'", "'", "'"],
            \ 'up-left-d': ['.', '.', '.', '.', '.', '.'],
            \ 'right-up-s': ["'", "'", "'", "'", "'", "'"], 
            \ 'right-up-d': ["'", "'", "'", "'", "'", "'"], 
            \ 'right-down-s': ['.', '.', '.', '.', '.', '.'],
            \ 'right-down-d': ["'", "'", "'", "'", "'", "'"], 
            \ 'left-down-s': ['.', '.', '.', '.', '.', '.'],
            \ 'left-down-d': ["'", "'", "'", "'", "'", "'"], 
            \ 'left-up-s': ["'", "'", "'", "'", "'", "'"], 
            \ 'left-up-d': ["'", "'", "'", "'", "'", "'"], 
            \ 'up-right-s': ["'", "'", "'", "'", "'", "'"], 
            \ 'up-right-d': ['.', '.', '.', '.', '.', '.'],
            \ 'down-left-s': ["'", "'", "'", "'", "'", "'"], 
            \ 'down-left-d': ["'", "'", "'", "'", "'", "'"], 
            \ 'down-right-s': ["'", "'", "'", "'", "'", "'"], 
            \ 'down-right-d': ["'", "'", "'", "'", "'", "'"], 
            \}

let g:vimio_config_draw_cross_styles = [
    \ {
    \ },
    \ {
    \ '+' : ')',
    \ '┼' : ')',
    \ '╋' : '❫',
    \ '╬' : '⟫',
    \ '╫' : '⟫',
    \ '╪' : ')',
    \ '┽' : ')',
    \ '┾' : ')',
    \ '┿' : ')',
    \ '╀' : ')',
    \ '╁' : ')',
    \ '╂' : '❫',
    \ '╃' : ')',
    \ '╄' : ')',
    \ '╅' : ')',
    \ '╆' : ')',
    \ '╇' : ')',
    \ '╈' : ')',
    \ '╉' : '❫',
    \ '╊' : '❫'
    \ },
    \ {
    \ '╭' : '┌',
    \ '╰' : '└',
    \ '╯' : '┘',
    \ '╮' : '┐'
    \ }
    \ ]

let g:vimio_config_arrow_chars_map = {
    \ 'up': {
    \ '-': ''  , '|': '^' , '+': '^' , '.': ''  , "'": ''  , '^': '^' , 'v': ''  , '<': ''  , '>': ''  ,
    \ '─': ''  , '│': '^'  , '┼': '^' , '┤': '^' , '├': '^' , '┬': ''  , '┴': '^' , '╭': ''  , '╮': ''  , '╯': '^' , '╰': '^' ,
    \ '━': ''  , '┃': '▲' , '╋': '▲' , '┫': '▲' , '┣': '▲' , '┳': ''  , '┻': '▲' , '┏': ''  , '┓': ''  , '┛': '▲' , '┗': '▲' ,
    \ '═': ''  , '║': '△' , '╬': '△' , '╣': '△' , '╠': '△' , '╦': ''  , '╩': '△' , '╔': ''  , '╗': ''  , '╝': '△' , '╚': '△' ,
    \ '╫': '△' , '╪': '^' , '╨': '△' , '╧': '^' , '╥': ''  , '╤': ''  , '╢': '△' , '╡': '^' , '╟': '△' , '╞': '^' , '╜': '△' ,
    \ '╛': '^' , '╙': '△' , '╘': '^' , '╖': ''  , '╕': ''  , '╓': ''  , '╒': ''  ,
    \ '┍': ''  , '┎': ''  , '┑': ''  , '┒': ''  , '┕': '^' , '┖': '▲' , '┙': '^' , '┚': '▲' ,
    \ '┝': '^' , '┞': '▲' , '┟': '^' , '┠': '▲' , '┡': '▲' , '┢': '^' ,
    \ '┥': '^' , '┦': '▲' , '┧': '^' , '┨': '▲' , '┩': '▲' , '┪': '^' ,
    \ '┭': ''  , '┮': ''  , '┯': ''  , '┰': ''  , '┱': ''  , '┲': ''  ,
    \ '┵': '^' , '┶': '^' , '┷': '^' , '┸': '▲' , '┹': '▲' , '┺': '▲' ,
    \ '┽': '^' , '┾': '^' , '┿': '^' , '╀': '▲' , '╁': '^' , '╂': '▲' , '╃': '▲' ,
    \ '╄': '▲' , '╅': '^' , '╆': '^' , '╇': '▲' , '╈': '^' , '╉': '▲' , '╊': '▲' ,
    \ '┌': ''  , '┐': ''  , '└': '^' , '┘': '^' , '┅': ''  , '┄': ''  , '┆': '^' , '┇': '▲' , ')': '^' , '❫': '▲' , '⟫': '△',
    \ '/': '^', '\': '^'
    \ },
    \   'down': {
    \ '-': '', '|': 'v', '+': 'v', '.': '', "'": '', '^': '', 'v': 'v', '<': '', '>': '',
    \ '─': '', '│': 'v', '┼': 'v', '┤': 'v', '├': 'v', '┬': 'v', '┴': '', '╭': 'v', '╮': 'v', '╯': '', '╰': '',
    \ '━': '', '┃': '▼', '╋': '▼', '┫': '▼', '┣': '▼', '┳': '▼', '┻': '', '┏': '▼', '┓': '▼', '┛': '', '┗': '',
    \ '═': '', '║': '▽', '╬': '▽', '╣': '▽', '╠': '▽', '╦': '▽', '╩': '', '╔': '▽', '╗': '▽', '╝': '', '╚': '',
    \ '╫': '▽', '╪': 'v', '╨': '', '╧': '', '╥': '▽', '╤': 'v', '╢': '▽', '╡': 'v', '╟': '▽', '╞': 'v', '╜': '',
    \ '╛': '', '╙': '', '╘': '', '╖': '▽', '╕': 'v', '╓': '▽', '╒': 'v',
    \ '┍': 'v', '┎': '▼', '┑': 'v', '┒': '▼', '┕': '', '┖': '', '┙': '', '┚': '',
    \ '┝': 'v', '┞': 'v', '┟': '▼', '┠': '▼', '┡': 'v', '┢': '▼',
    \ '┥': 'v', '┦': 'v', '┧': '▼', '┨': '▼', '┩': 'v', '┪': '▼',
    \ '┭': 'v', '┮': 'v', '┯': 'v', '┰': '▼', '┱': '▼', '┲': '▼',
    \ '┵': '', '┶': '', '┷': '', '┸': '', '┹': '', '┺': '',
    \ '┽': 'v', '┾': 'v', '┿': 'v', '╀': 'v', '╁': 'v', '╂': '▼', '╃': 'v',
    \ '╄': 'v', '╅': '▼', '╆': '▼', '╇': 'v', '╈': '▼', '╉': '▼', '╊': '▼',
    \ '┌': 'v', '┐': 'v', '└': '', '┘': '', '┅': '', '┄': '', '┆': 'v', '┇': '▼', ')': 'v', '❫': '▼', '⟫': '▽',
    \ '/': 'v', '\': 'v'
    \ }, 
    \   'left': {
    \ '-': '<', '|': '', '+': '<', '.': '', "'": '', '^': '', 'v': '', '<': '<', '>': '',
    \ '─': '<', '│': '', '┼': '<', '┤': '<', '├': '', '┬': '<', '┴': '<', '╭': '', '╮': '<', '╯': '<', '╰': '',
    \ '━': '◀', '┃': '', '╋': '◀', '┫': '◀', '┣': '', '┳': '◀', '┻': '◀', '┏': '', '┓': '◀', '┛': '◀', '┗': '',
    \ '═': '◁', '║': '', '╬': '◁', '╣': '◁', '╠': '', '╦': '◁', '╩': '◁', '╔': '', '╗': '◁', '╝': '◁', '╚': '',
    \ '╫': '<', '╪': '◁', '╨': '<', '╧': '◁', '╥': '<', '╤': '◁', '╢': '<', '╡': '◁', '╟': '', '╞': '', '╜': '<',
    \ '╛': '◁', '╙': '', '╘': '', '╖': '<', '╕': '◁', '╓': '', '╒': '',
    \ '┍': '', '┎': '', '┑': '◀', '┒': '<', '┕': '', '┖': '', '┙': '◀', '┚': '<',
    \ '┝': '', '┞': '', '┟': '', '┠': '', '┡': '', '┢': '',
    \ '┥': '◀', '┦': '<', '┧': '<', '┨': '<', '┩': '◀', '┪': '◀',
    \ '┭': '◀', '┮': '<', '┯': '◀', '┰': '<', '┱': '◀', '┲': '<',
    \ '┵': '◀', '┶': '<', '┷': '◀', '┸': '<', '┹': '◀', '┺': '<',
    \ '┽': '◀', '┾': '<', '┿': '◀', '╀': '<', '╁': '<', '╂': '<', '╃': '◀',
    \ '╄': '<', '╅': '◀', '╆': '<', '╇': '◀', '╈': '◀', '╉': '◀', '╊': '<',
    \ '┌': '', '┐': '<', '└': '', '┘': '<', '┅': '◀', '┄': '<', '┆': '', '┇': '', ')': '', '❫': '', '⟫': '',
    \ '/': '<', '\': '<'
    \ },
    \   'right': {
    \ '-': '>', '|': '', '+': '>', '.': '', "'": '', '^': '', 'v': '', '<': '', '>': '>',
    \ '─': '>', '│': '', '┼': '>', '┤': '', '├': '>', '┬': '>', '┴': '>', '╭': '>', '╮': '', '╯': '', '╰': '>',
    \ '━': '▶', '┃': '', '╋': '▶', '┫': '', '┣': '▶', '┳': '▶', '┻': '▶', '┏': '▶', '┓': '', '┛': '', '┗': '▶',
    \ '═': '▷', '║': '', '╬': '▷', '╣': '', '╠': '▷', '╦': '▷', '╩': '▷', '╔': '▷', '╗': '', '╝': '', '╚': '▷',
    \ '╫': '>', '╪': '▷', '╨': '>', '╧': '▷', '╥': '>', '╤': '▷', '╢': '', '╡': '', '╟': '>', '╞': '▷', '╜': '',
    \ '╛': '', '╙': '>', '╘': '▷', '╖': '', '╕': '', '╓': '>', '╒': '▷',
    \ '┍': '▶', '┎': '>', '┑': '', '┒': '', '┕': '▶', '┖': '>', '┙': '', '┚': '',
    \ '┝': '▶', '┞': '>', '┟': '>', '┠': '>', '┡': '▶', '┢': '▶',
    \ '┥': '', '┦': '', '┧': '', '┨': '', '┩': '', '┪': '',
    \ '┭': '>', '┮': '▶', '┯': '▶', '┰': '>', '┱': '>', '┲': '▶',
    \ '┵': '>', '┶': '▶', '┷': '▶', '┸': '>', '┹': '>', '┺': '▶',
    \ '┽': '>', '┾': '▶', '┿': '▶', '╀': '>', '╁': '>', '╂': '>', '╃': '>',
    \ '╄': '▶', '╅': '>', '╆': '▶', '╇': '▶', '╈': '▶', '╉': '>', '╊': '▶',
    \ '┌': '>', '┐': '', '└': '>', '┘': '', '┅': '▶', '┄': '>', '┆': '', '┇': '', ')': '', '❫': '', '⟫': '',
    \ '/': '>', '\': '>'
    \ }
    \ }


let g:vimio_config_border_chars = {
    \ '|' : 1, '-' : 1, '+' : 1, '.' : 1, "'" : 1, '`' : 1, '/' : 1, '\' : 1, ':': 1, '_': 1,
    \ '─': 1, '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╮': 1, '╯': 1, '╰': 1,
    \ '━': 1, '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┓': 1, '┛': 1, '┗': 1,
    \ '═': 1, '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╗': 1, '╝': 1, '╚': 1,
    \ '╫': 1, '╪': 1, '╨': 1, '╧': 1, '╥': 1, '╤': 1, '╢': 1, '╡': 1, '╟': 1, '╞': 1, '╜': 1,
    \ '╛': 1, '╙': 1, '╘': 1, '╖': 1, '╕': 1, '╓': 1, '╒': 1,
    \ '┍': 1, '┎': 1, '┑': 1, '┒': 1, '┕': 1, '┖': 1, '┙': 1, '┚': 1,
    \ '┝': 1, '┞': 1, '┟': 1, '┠': 1, '┡': 1, '┢': 1,
    \ '┥': 1, '┦': 1, '┧': 1, '┨': 1, '┩': 1, '┪': 1,
    \ '┭': 1, '┮': 1, '┯': 1, '┰': 1, '┱': 1, '┲': 1,
    \ '┵': 1, '┶': 1, '┷': 1, '┸': 1, '┹': 1, '┺': 1,
    \ '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1,
    \ '╄': 1, '╅': 1, '╆': 1, '╇': 1, '╈': 1, '╉': 1, '╊': 1,
    \ '┌': 1, '┐': 1, '└': 1, '┘': 1, '┅': 1, '┄': 1, '┆': 1, '┇': 1, ')': 1, '❫': 1, '⟫': 1, '▲': 1, '▼': 1, '◀': 1, '▶': 1,
    \ '△': 1, '▽': 1, '◁': 1, '▷': 1
    \ }

let g:vimio_config_line_chars = {
    \ '|' : 1, '-' : 1, '+' : 1, '.' : 1, "'" : 1, '`' : 1, '/' : 1, '\' : 1,
    \ '─': 1, '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╮': 1, '╯': 1, '╰': 1,
    \ '━': 1, '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┓': 1, '┛': 1, '┗': 1,
    \ '═': 1, '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╗': 1, '╝': 1, '╚': 1,
    \ '╫': 1, '╪': 1, '╨': 1, '╧': 1, '╥': 1, '╤': 1, '╢': 1, '╡': 1, '╟': 1, '╞': 1, '╜': 1,
    \ '╛': 1, '╙': 1, '╘': 1, '╖': 1, '╕': 1, '╓': 1, '╒': 1,
    \ '┍': 1, '┎': 1, '┑': 1, '┒': 1, '┕': 1, '┖': 1, '┙': 1, '┚': 1,
    \ '┝': 1, '┞': 1, '┟': 1, '┠': 1, '┡': 1, '┢': 1,
    \ '┥': 1, '┦': 1, '┧': 1, '┨': 1, '┩': 1, '┪': 1,
    \ '┭': 1, '┮': 1, '┯': 1, '┰': 1, '┱': 1, '┲': 1,
    \ '┵': 1, '┶': 1, '┷': 1, '┸': 1, '┹': 1, '┺': 1,
    \ '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1,
    \ '╄': 1, '╅': 1, '╆': 1, '╇': 1, '╈': 1, '╉': 1, '╊': 1,
    \ '┌': 1, '┐': 1, '└': 1, '┘': 1, '┅': 1, '┄': 1, '┆': 1, '┇': 1, ')': 1, '❫': 1, '⟫': 1, '▲': 1, '▼': 1, '◀': 1, '▶': 1,
    \ '△': 1, '▽': 1, '◁': 1, '▷': 1, '<': 1, '>': 1, '^': 1, 'v': 1,
    \ }

let g:vimio_config_non_text_borders = {
    \ '|' : 1, '-' : 1, '+' : 1, 
    \ '─': 1, '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╮': 1, '╯': 1, '╰': 1,
    \ '━': 1, '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┓': 1, '┛': 1, '┗': 1,
    \ '═': 1, '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╗': 1, '╝': 1, '╚': 1,
    \ '╫': 1, '╪': 1, '╨': 1, '╧': 1, '╥': 1, '╤': 1, '╢': 1, '╡': 1, '╟': 1, '╞': 1, '╜': 1,
    \ '╛': 1, '╙': 1, '╘': 1, '╖': 1, '╕': 1, '╓': 1, '╒': 1,
    \ '┍': 1, '┎': 1, '┑': 1, '┒': 1, '┕': 1, '┖': 1, '┙': 1, '┚': 1,
    \ '┝': 1, '┞': 1, '┟': 1, '┠': 1, '┡': 1, '┢': 1,
    \ '┥': 1, '┦': 1, '┧': 1, '┨': 1, '┩': 1, '┪': 1,
    \ '┭': 1, '┮': 1, '┯': 1, '┰': 1, '┱': 1, '┲': 1,
    \ '┵': 1, '┶': 1, '┷': 1, '┸': 1, '┹': 1, '┺': 1,
    \ '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1,
    \ '╄': 1, '╅': 1, '╆': 1, '╇': 1, '╈': 1, '╉': 1, '╊': 1,
    \ '┌': 1, '┐': 1, '└': 1, '┘': 1, '┅': 1, '┄': 1, '┆': 1, '┇': 1, ')': 1, '❫': 1, '⟫': 1, '▲': 1, '▼': 1, '◀': 1, '▶': 1,
    \ '△': 1, '▽': 1, '◁': 1, '▷': 1, '<': 1, '>': 1, '^': 1, 'v': 1, ' ': 1,
    \ '/': 1, '\': 1
    \ }

