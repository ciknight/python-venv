if exists("g:virtualenv_loaded")
    finish
endif

if !has('python3')
    finish
endif


" --------------------------------
" Add our plugin to the path
" --------------------------------
python3 import vim, sys
"python3 if vim.eval('expand("<sfile>:p:h")') not in sys.path: sys.path.append(vim.eval('expand("<sfile>:p:h")'))

" --------------------------------
"  Function(s)
" --------------------------------
function! SetPipEnvVEnv()

  python3 << endOfPython
import os
import sys
import pathlib
python_venv_path = vim.eval('g:python_venv_path')

# jedi-vim
activate_this = os.path.join(python_venv_path, 'bin/activate_this.py')
with open(activate_this) as f:
     exec(f.read(), {'__file__': activate_this})

python_venv_site_pkg_path = next(pathlib.Path(python_venv_path, 'lib').glob('python*/site-packages'), None)
vim.command("let g:python_venv_site_pkg_path='{}'".format(python_venv_site_pkg_path))
endOfPython

" https://github.com/Shougo/deoplete.nvim/issues/613
" deoplete-jedi
if exists('g:python_venv_site_pkg_path')
  let $PYTHONPATH=g:python_venv_site_pkg_path.':'.$PYTHONPATH
endif
"if exists('g:deoplete#sources#jedi')
"  let g:deoplete#sources#jedi#extra_path=$PYTHONPATH
"endif
echo 'Set pipenv venv success'
endfunction

" {{{
function! FoundPipEnv()
  let pipenv_venv_path = system('pipenv --venv')
  " if error return 1, No virtualenv has been created
  if shell_error == 0
    let g:python_venv_path = substitute(pipenv_venv_path, '\n', '', '')
    call SetPipEnvVEnv()
  else
    echo 'No pipenv venv'
  endif
endfunction
" }}}

" {{{
function! LoadProjectPythonPath()

endfunction

" }}}

function! SetPythonVEnv()
  call FoundPipEnv()
endfunction

" --------------------------------
"  Expose our commands to the user
" --------------------------------
augroup auto_set_python_venv
  autocmd BufNewFile,BufRead *.py call SetPythonVEnv()
augroup END
