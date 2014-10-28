let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_snippet_engine = "neosnippet"

function! golang#generate_project()
  call system('find . -iname "*.go" > /tmp/gotags-filelist-project')
  let gopath = substitute(system('go env GOPATH'), '\n', '', '')
  call vimproc#system_bg('gotags -silent -L /tmp/gotags-filelist-project > ' . gopath . '/tags')
endfunction

function! golang#generate_global()
  call system('find `go env GOROOT GOPATH` -iname "*.go" > /tmp/gotags-filelist-global')
  let gopath = substitute(system('go env GOPATH'), '\n', '', '')
  call vimproc#system_bg('gotags -silent -L /tmp/gotags-filelist-global > ' . gopath . '/tags')
endfunction

function! golang#buffcommands()
  command! -buffer -bar -nargs=0 GoTags call golang#generate_project()
  command! -buffer -bar -nargs=0 GoTagsGlobal call golang#generate_global()
  setlocal shiftwidth=2 tabstop=2 softtabstop=2 noexpandtab
endfunction

function! golang#syn_if_longfile(param)
  let l:linecount = line('$')
  if linecount > 1500
    execute "syn ".a:param
  endif
endfunction

let s:projections = {
      \ '*': {},
      \ '*.go': {'type': 'go', 'alternate': ['{}_test.go']},
      \ '*_suite_test.go': {'type': 'suite'},
      \ '*_test.go': {
      \   'type': 'test',
      \   'alternate': '{}.go'}}

function! s:ProjectionistDetect() abort
  if &ft=='go'
    let projections = deepcopy(s:projections)
    call projectionist#append(getcwd(), projections)
  endif
endfunction

augroup go_projectionist
  autocmd!
  autocmd User ProjectionistDetect call s:ProjectionistDetect()
augroup END

augroup go_fastgo
  autocmd!
  autocmd BufWritePre *.go call golang#syn_if_longfile('off')
  autocmd BufWritePost *.go call golang#syn_if_longfile('on')
augroup END

if exists("g:disable_gotags_on_save") && g:disable_gotags_on_save
  augroup go_gotags
    autocmd!
    autocmd BufWritePost *.go call golang#generate_project()
    autocmd BufWritePost *.go call golang#generate_global()
  augroup END
endif

:autocmd FileType go nmap <buffer> G? <Plug>(go-doc-browser)
:autocmd FileType go nmap <buffer> GV <Plug>(go-vet)
:autocmd FileType go nmap <buffer> GL <Plug>(go-lint)
:autocmd FileType go nmap <buffer> GC <Plug>(go-coverage)
:autocmd FileType go nmap <buffer> GR <Plug>(go-)
:autocmd FileType go nmap <buffer> GR <Plug>(go-rename)

" command! -range=% GoOracleDescribe call go#oracle#Describe(<count>)
" command! -range=% GoOracleCallees  call go#oracle#Callees(<count>)
" command! -range=% GoOracleCallers call go#oracle#Callers(<count>)
" command! -range=% GoOracleCallgraph call go#oracle#Callgraph(<count>)
" command! -range=% GoOracleCallstack call go#oracle#Callstack(<count>)
" command! -range=% GoOracleFreevars call go#oracle#Freevars(<count>)
" command! -range=% GoOraclePeers call go#oracle#Peers(<count>)
" command! -range=% GoOracleReferrers call go#oracle#Referrers(<count>)
