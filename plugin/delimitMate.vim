" ============================================================================
" File:        plugin/delimitMate.vim
" Version:     2.4DEV
" Modified:    2010-06-06
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".

" Initialization: {{{

if exists("g:loaded_delimitMate")
	" User doesn't want this plugin, let's get out!
	finish
endif
let g:loaded_delimitMate = 1

if exists("s:loaded_delimitMate") && !exists("g:delimitMate_testing")
	" Don't define the functions if they already exist: just do the work
	" (unless we are testing):
	call s:DelimitMateDo()
	finish
endif

if v:version < 700
	echoerr "delimitMate: this plugin requires vim >= 7!"
	finish
endif

let s:loaded_delimitMate = 1
let delimitMate_version = "2.4DEV"
"}}}

" Functions: {{{

function! s:TestMappingsDo() "{{{
	if !exists("g:delimitMate_testing")
		silent call delimitMate#TestMappings()
	else
		let temp_varsDM = [b:delimitMate_expand_space, b:delimitMate_expand_cr, b:delimitMate_autoclose]
		for i in [0,1]
			let b:delimitMate_expand_space = i
			let b:delimitMate_expand_cr = i
			for a in [0,1]
				let b:delimitMate_autoclose = a
				call delimitMate#Init()
				call delimitMate#TestMappings()
				exec "normal i\<CR>"
			endfor
		endfor
		let b:delimitMate_expand_space = temp_varsDM[0]
		let b:delimitMate_expand_cr = temp_varsDM[1]
		let b:delimitMate_autoclose = temp_varsDM[2]
		unlet temp_varsDM
	endif
	normal gg
endfunction "}}}

function! s:DelimitMateDo(...) "{{{
	if exists("g:delimitMate_excluded_ft")
		" Check if this file type is excluded:
		if index(split(g:delimitMate_excluded_ft, ','), &filetype, 0, 1) >= 0
			if !exists('b:delimitMate_enabled')
				call delimitMate#Init()
			endif
			call delimitMate#UnMap()
			return 1
		endif
	endif
	call delimitMate#Init()
	if a:0 > 0
		echo "delimitMate has been reset."
	endif
endfunction "}}}

function! s:DelimitMateSwitch() "{{{
	if b:delimitMate_enabled
		call delimitMate#UnMap()
		echo "delimitMate has been disabled."
	else
		call delimitMate#Init()
		echo "delimitMate has been enabled."
	endif
endfunction "}}}

"}}}

" Commands: {{{

call s:DelimitMateDo()

" Let me refresh without re-loading the buffer:
command! DelimitMateReload call s:DelimitMateDo(1)

" Quick test:
command! DelimitMateTest call s:TestMappingsDo()

" Switch On/Off:
command! DelimitMateSwitch call s:DelimitMateSwitch()
"}}}

" Autocommands: {{{

augroup delimitMate
	au!
	" Run on file type change.
	"autocmd VimEnter * autocmd FileType * call <SID>DelimitMateDo()
	autocmd FileType * call <SID>DelimitMateDo()

	" Run on new buffers.
	autocmd BufNewFile,BufRead,BufEnter * if !exists("b:loaded_delimitMate") | call <SID>DelimitMateDo() | endif

	" Flush the char buffer:
	autocmd InsertEnter * call delimitMate#FlushBuffer()
	autocmd BufEnter * if mode() == 'i' | call delimitMate#FlushBuffer() | endif

augroup END

"}}}

" GetLatestVimScripts: 2754 1 :AutoInstall: delimitMate.vim
" vim:foldmethod=marker:foldcolumn=4
