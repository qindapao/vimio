function! Vimio__DefineSmartDrawShapesanimal(indexes, index)
    let cat =<< EOF
   /\_/\ 
  ( o.o )
   > ^ <
EOF
    let dog =<< EOF
  _=,_
o_/6 /#\
\__ |##/
='|--\
  /   #'-.
  \#|_   _'-. /
   |/ \_( # |" 
  C/ ,--___/
EOF

    
    let l:snapshot =<< EOF
0   1
cat dog
EOF

    let vimio_config_shapes = {'set_index': a:index, 'stencil_set_name': 'animals', 'value': [
        \ {
        \ 'index': a:indexes[0],
        \ 'name': 'animals',
        \ 'snapshot': join(l:snapshot, "\n"),
        \ 'step': [1, 1],
        \ 'value': [ cat, dog ]
        \ }
        \ ],
        \ }
    return vimio_config_shapes
endfunction

