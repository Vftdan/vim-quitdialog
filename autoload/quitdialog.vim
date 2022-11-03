function! quitdialog#get_any_var(name, default)
	let l:G = get(g:, a:name, a:default)
	let l:B = get(b:, a:name, l:G)
	return    get(w:, a:name, l:B)
endfunction

function! quitdialog#get_plugin_setting(name, default, isfunc)
	return quitdialog#get_any_var((a:isfunc ? 'Q' : 'q') . 'uitdialog_' . a:name, a:default)
endfunction

function! quitdialog#prompt_char(msg)
	echo a:msg
	redraw
	return nr2char(getchar())
endfunction

function! quitdialog#prompt_yn(msg, default)
	let l:suffix = a:default ? '[y]/n' : 'y/[n]'
	let l:msg = a:msg . ' (' . l:suffix . ')'
	let l:ch = quitdialog#prompt_char(l:msg)
	if a:default
		return l:ch !=? 'n'
	else
		return l:ch ==? 'y'
	endif
endfunction

function! quitdialog#quit_handler()
	if !quitdialog#prompt_yn(quitdialog#get_plugin_setting('message', 'Exit Vim?', v:false),
			      \ quitdialog#get_plugin_setting('default', v:true, v:false))
		call quitdialog#get_plugin_setting('abort_function', function('quitdialog#prevent_quit'), v:true)()
	endif
endfunction

let s:buf = -1
function! quitdialog#prevent_quit()
	let l:lz = &lazyredraw
	let l:hid = &hidden
	let l:awa = &autowriteall
	set lazyredraw hidden noautowriteall
	tabnew
	set modified
	if s:buf == -1 || !bufexists(s:buf)
		let s:buf = bufadd('')
	endif
	call bufload(s:buf)
	call setbufvar(s:buf, '&modified', 1)
	echo ''
	let l:win = win_getid()
	function! s:cleanup(...) closure
		call setbufvar(s:buf, '&modified', 0)
		" It seems that there is no way to completely delete it from
		" buffer list.
		exe s:buf . 'bdelete'
		if win_gotoid(l:win)
			set nomodified
			q
			redraw
		endif
		let &autowriteall = l:awa
		let &hidden = l:hid
		let &lazyredraw = l:lz
	endfunction
	call timer_start(0, funcref('s:cleanup'))
endfunction
