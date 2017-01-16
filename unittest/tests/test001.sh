succes_cmd="echom \"unittest succeded\""
source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/.vimrc <<EOL
EOL

cat >>$vimtestdir/test.vim <<EOL

let s:cur_debug_pid = 0

function! s:DebugMove(delta)
	let g:players[s:cur_debug_pid].range[1] += a:delta
	let g:players[s:cur_debug_pid].range[3] += a:delta
	call SendCursor(s:cur_debug_pid)
endfunction


function! s:DebugConnect()
	let s:cur_debug_pid = CreatePlayer()
	call s:DebugChange(s:cur_debug_pid-1000000)
	call SendUnicastMsg('hello', s:cur_debug_pid, [])
	call SendUnicastMsg('iam', s:cur_debug_pid, ["debug".s:cur_debug_pid])
	call SendCursor(s:cur_debug_pid)
	nnoremap <UP> :call <SID>DebugMove(-1)<CR>
	nnoremap <DOWN> :call <SID>DebugMove(1)<CR>
endfunction

function! s:DebugChange(count)
	if s:cur_debug_pid != 0 && a:count == 0
		let s:cur_debug_pid = 0
		nunmap <UP>
		nunmap <DOWN>
	elseif s:cur_debug_pid == 0 && a:count != 0
		nnoremap <UP> :call <SID>DebugMove(-1)<CR>
		nnoremap <DOWN> :call <SID>DebugMove(1)<CR>
	endif
	if a:count != 0
		let s:cur_debug_pid = 1000000 + a:count
	endif
endfunction

function! s:DebugDisconnect()
endfunction

execute "nnoremap <silent> mc :<C-U>call <SID>DebugConnect()<CR>"
execute "nnoremap <silent> mm :<C-U>call <SID>DebugChange(v:count)<CR>"
execute "nnoremap <silent> md :<C-U>call <SID>DebugDisconnect()<CR>"


function! s:getMsg(pid)
	if len(g:players[a:pid].msgs) == 0
		return 0
	endif
	let ret = g:players[a:pid].msgs[0]
	let g:players[a:pid].msgs = g:players[a:pid].msgs[1:]
	return ret
endfunction

function! s:mkMsg(command, buffer, msg)
	return [a:command, string(getpid()), a:buffer, string(len(a:msg))] + a:msg
endfunction

call system('rm /tmp/vim_multi_player_pipe_100000*')
sleep 200m

MultiplayerConnect
sleep 200m

let my_pid = CreatePlayer()
sleep 200m
call SendUnicastMsg("hello", my_pid, [])
sleep 1200m

call assert_equal(s:mkMsg('iam', "a.txt", ['noname']), s:getMsg(my_pid))
call assert_equal(s:mkMsg('cursor', "a.txt", ['n', '1', '1', '1', '1']), s:getMsg(my_pid))
call assert_equal(0, s:getMsg(my_pid))

call SendUnicastMsg("iam", my_pid, ['Tester'])
call SendCursor(my_pid)
call SendUnicastMsg("diff", my_pid, ['1c1', '< ', '---', '> hello world'])
sleep 200m
call assert_equal(0, s:getMsg(my_pid))

call assert_equal(['hello world'], getline(1, '$'))
call SendUnicastMsg("diff", my_pid, ['1a2,3', "> \<TAB>12345\<TAB>123", '> 123456789'])
sleep 200m
call assert_equal(['hello world', "\<TAB>12345\<TAB>123", '123456789'], getline(1, '$'))

let g:players[my_pid].range = ['6', '2', '6', '2']
call SendCursor(my_pid)
sleep 200m
let m = getmatches()
call assert_equal(1, len(m))
call assert_equal('MPCol2', m[0].group)
call assert_equal('\%>5v\%<7v\%2l', m[0].pattern)
call assert_equal(0, s:getMsg(my_pid))

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim: