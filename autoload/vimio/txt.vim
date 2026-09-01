" autoload/vimio/txt.vim
" -----------------
" Specifically dealing with text-related
"
function! vimio#txt#change_clipboard_txt_column_width(algorithm, step) abort
    let text = getreg('+')
    if text ==# '' | return | endif

    " 如果算法是 'word'，使用基于单词的换行
    if a:algorithm ==# 'word'
        " 规范化文本：去除换行，并将连续空白压缩为单个空格
        let clean = substitute(text, '\r', '', 'g')
        let clean = substitute(clean, '\n\+', ' ', 'g')
        let clean = substitute(clean, '^\s\+\|\s\+$', '', 'g')
        let clean = substitute(clean, '\s\+', ' ', 'g')
        if empty(clean) | return | endif

        " 纯粹按【非空单词】拆分（忽略空格 Token，方便精确控制）
        let words = split(clean, ' ')
        if empty(words) | return | endif

        let word_widths = map(copy(words), 'strdisplaywidth(v:val)')
        let min_w = max(word_widths)   " 绝对下限：不能小于最长单个单词

        " 获取原文本第一行（用于计算初始吞吐单词数 N）
        let lines = split(text, '[\r\n]\+')
        let first_line = get(lines, 0, '')

        " 计算原第一行能完整包含前多少个【真正的单词】
        let N = 0
        let cur_w = 0
        for i in range(len(words))
            let w = word_widths[i]
            " 单词间需要算上 1 个空格的宽度
            let need_w = (N == 0) ? w : (w + 1)
            if cur_w + need_w <= strdisplaywidth(first_line)
                let cur_w += need_w
                let N += 1
            else
                break
            endif
        endfor

        " 如果第一行极短，至少算它包含了 1 个单词
        if N == 0 | let N = 1 | endif

        " 根据步长调整目标单词数 N_target
        let N_target = N + a:step
        let N_target = max([1, min([N_target, len(words)])])

        " 计算真实的 target_w（前 N_target 个单词及其间隔空格的总宽度）
        let target_w = 0
        for i in range(N_target)
            let target_w += word_widths[i] + (i > 0 ? 1 : 0)
        endfor
        let target_w = max([target_w, min_w])

        " 按计算出的 target_w 重新贪心装载单词
        let new_lines = []
        let cur_line = ''
        let cur_w = 0

        for word in words
            let w = strdisplaywidth(word)

            if cur_w == 0
                let cur_line = word
                let cur_w = w
            elseif cur_w + 1 + w <= target_w
                let cur_line .= ' ' . word
                let cur_w += 1 + w
            else
                call add(new_lines, cur_line)
                let cur_line = word
                let cur_w = w
            endif
        endfor

        if cur_w > 0
            call add(new_lines, cur_line)
        endif

        " 用安全的换行符连接写入剪贴板
        call setreg('+', join(new_lines, "\n"))
        call vimio#popup#update_cross_block()
        return
    endif

    " ---- 原有基于字符的算法（保持不变） ----
    let lines = split(text, '[\r\n]\+')
    let chars = split(substitute(text, '[\r\n]', '', 'g'), '\zs')
    if empty(chars) | return | endif

    let min_w = max(map(copy(chars), 'strdisplaywidth(v:val)'))
    let curr_max_w = max(map(copy(lines), 'strdisplaywidth(v:val)'))
    let target_w = curr_max_w + a:step

    if a:step > 0 && (target_w - curr_max_w) < min_w
        let target_w = curr_max_w + min_w
    endif
    let target_w = max([target_w, min_w])

    let [new_lines, cur_line, cur_w] = [[], '', 0]
    for c in chars
        let w = strdisplaywidth(c)
        if cur_w + w > target_w && cur_w > 0
            call add(new_lines, cur_line)
            let [cur_line, cur_w] = [c, w]
        else
            let [cur_line, cur_w] = [cur_line . c, cur_w + w]
        endif
    endfor
    if cur_w > 0 | call add(new_lines, cur_line) | endif

    call setreg('+', join(new_lines, "\n"))
    call vimio#popup#update_cross_block()
endfunction

