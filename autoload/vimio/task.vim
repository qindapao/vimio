" autoload/vimio/task.vim

let s:vimio_active_timer = -1


function! vimio#task#run_draw_queue(tasklist, interval, ...) abort
    " If the previous timer is still active, shut it down directly.
    if s:vimio_active_timer != -1
        call timer_stop(s:vimio_active_timer)
        let s:vimio_active_timer = -1
    endif

    " Create a copy to prevent the original list from being contaminated.
    let l:queue = copy(a:tasklist)

    if a:0 && a:1 ==# 'sync'
        " Synchronous Execution: No timers are used; all tasks are completed immediately.
        while !empty(l:queue)
            let l:item = remove(l:queue, 0)
            " if has_key(l:item, 'draw') && type(l:item.draw) == type(function('tr'))
            call l:item.draw()
            " endif
        endwhile
        let s:vimio_active_timer = -1
        return
    endif

    " Defining Scheduler Functions
    function! s:next_draw(timer) closure
        if empty(l:queue)
            let s:vimio_active_timer = -1
            return
        endif

        " Retrieve and execute the head task of the queue.
        let l:item = remove(l:queue, 0)
        call l:item.draw()

        " If the queue still has tasks, continue scheduling.
        if !empty(l:queue)
            let s:vimio_active_timer = timer_start(a:interval, function('s:next_draw'))
        else
            let s:vimio_active_timer = -1
        endif
    endfunction

    " Start the first timer
    let s:vimio_active_timer = timer_start(a:interval, function('s:next_draw'))
endfunction

