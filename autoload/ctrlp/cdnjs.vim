function! s:compare_libname(lib1, lib2)
  return a:lib1.name ==? a:lib2.name ? 0 : a:lib1.name >? a:lib2.name ? 1 : -1
endfunction

function! s:insert_url(url)
  let line       = getline('.')
  let pos        = s:curpos[2] - 1
  let line       = line[: pos-1] . a:url . line[pos :]
  call setline('.', line)

  let curpos     = copy(s:curpos)
  let curpos[2] += len(a:url)
  call setpos('.', curpos)
endfunction

function! s:get_apis()
  let res = webapi#http#get('http://api.cdnjs.com/libraries', {'fields': 'version'})
  let libraries = webapi#json#decode(res.content)

  let s:list = sort(copy(libraries.results), 's:compare_libname')
  return map(copy(s:list), 'printf("%s (v%s)", v:val.name, v:val.version)')
endfunc

function! s:FZFCdnJsHandler(str)
  let library = filter(copy(s:list), 'v:val.name == split(a:str)[0]')[0]
  call append(line('.'), library.latest)
endfunction

command! FZFCdnJs cal fzf#run({
      \ 'source':  s:get_apis(),
      \ 'sink':   function('<sid>FZFCdnJsHandler'),
      \ })
