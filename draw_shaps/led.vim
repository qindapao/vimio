function! Vimio__DefineSmartDrawShapesLed(indexes, index)
    let l:led1 =<< EOF
 .-.
( ~ )
 '-'
EOF

    let l:led2 =<< EOF
  .
 /!\
'---'
EOF

    let l:led3 =<< EOF
 .-. .-.
|   | o |
|.-.|.-.|
EOF

    let l:led4 =<< EOF
 ─╮
╭─┼─╯
  ╰─
EOF

    let l:led5 =<< EOF
 ╭──────╮
[│ + -  │
 ╰──────╯
EOF

    let l:led6 =<< EOF
.---.
|888|
'---'
EOF
    let l:led7 =<< EOF
  .---.
 / .│. \
( (   ) )
 \ '-' /
  '---'
EOF
    let l:led8 =<< EOF
 .-_-.
( (^) )
 '-'\'
EOF

    let vimio_config_shapes = {'set_index': a:index, 'stencil_set_name': 'leds', 'snapshot': '', 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 1],
    \ 'name': 'leds',
    \ 'value': [ l:led1, l:led1, l:led3, l:led4, l:led5, l:led6, l:led7, l:led8 ]
    \ }
    \ ],
    \ }

    return vimio_config_shapes
endfunction

