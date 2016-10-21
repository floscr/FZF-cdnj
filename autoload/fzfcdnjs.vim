function! s:compare_libname(lib1, lib2)
  return a:lib1.name ==? a:lib2.name ? 0 : a:lib1.name >? a:lib2.name ? 1 : -1
endfunction

function! s:get_apis()
  let res = webapi#http#get('http://api.cdnjs.com/libraries', {'fields': 'version'})
  let libraries = webapi#json#decode(res.content)

  let s:list = sort(copy(libraries.results), 's:compare_libname')
  return map(copy(s:list), 'printf("%s (v%s)", v:val.name, v:val.version)')
endfunc

function! s:insert(str)
  let library = filter(copy(s:list), 'v:val.name == split(a:str)[0]')[0]
  call append(line('.'), library.latest)
endfunction

function! fzfcdnjs#init()
  cal fzf#run({
        \ 'source':  s:get_apis(),
        \ 'sink':   function('s:insert'),
        \ })
endfunction
