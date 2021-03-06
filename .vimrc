scriptencoding utf-8
" augroup がセットされていない autocmd 全般用の augroup
" これをやっておかないと ReloadVimrc したときに困る．by Linda_pp
augroup MyAutocmd
    autocmd!
augroup END

""" Options {{{
" Vi互換モードを使わない
set nocompatible
" シンタックスハイライト
syntax enable
" バックスペースでいろいろ消せる
set backspace=indent,eol,start
" バックアップファイルなし
set nobackup
" .viminfoファイル制限
set viminfo=!,'50,<1000,s100,\"50
" 履歴を500件まで保存する
set history=1000
" カーソル位置を表示する
set ruler
" スクロール時の余白確保
set scrolloff=5
" ファイルエンコーディングをutf-8優先
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,sjis,euc-jp
set fileformats=unix,mac,dos
" 行番号表示
set number
"" タブ幅 {{{
set showtabline=2
set expandtab       " タブをスペースに展開する
set tabstop=4       " 画面上のタブ幅
set shiftwidth=4    " インデント時に自動的に挿入されるタブ幅
set softtabstop=4   " キーボードで<Tab>キーを押したときに挿入される空白の量
set shiftround
set smarttab        " 行頭の余白内で<Tab>キーを押すとshiftwidthの数だけインデント．行頭以外ではtabstopの数だけ空白が挿入される．
"" }}}
" 改行時にコメントしない
set formatoptions-=ro
" 改行コードの自動認識
set fileformats=unix,mac,dos
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
set smartcase
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" ビープ音をOFFにする
set vb t_vb =
" ステータスラインを常に表示
set laststatus=2
" 括弧入力時の対応する括弧を表示
set showmatch
" IMを使う
set noimdisable
" コマンドラインでのIM無効化
set noimcmdline
" 入力中のコマンドをステータスに表示する
set showcmd
" 対応する括弧の行き来する時間の設定
set matchtime=3
" vimを開いた位置ではなくファイルのディレクトリ位置を起点にする
set browsedir=buffer
" コピペにクリップボードを使用する
" ビジュアルモードで選択したテキストが、クリップボードに入るようにす
set clipboard=unnamedplus,autoselect
" 文字にアンチエイリアスをかける
if has('mac') && has('gui_running')
  set antialias
endif
" 外部のエディタで編集中のファイルが変更されたら自動で読み直す
set autoread
" 辞書ファイルからの単語補間
set complete+=k
" 高速ターミナル接続を行う
set ttyfast
" {{{}}}で折りたたみ
set foldmethod=marker
" カーソル下の単語を help で調べる
set keywordprg=:help
" コマンド表示いらない
set noshowcmd
" コマンド実行中は再描画しない
set lazyredraw
" 読み込んでいるファイルが変更された時自動で読み直す
set autoread
" マルチバイト文字があってもカーソルがずれないようにする
set ambiwidth=double
" 256色
set t_Co=256
" タブ文字を CTRL-I で表示し, 行末に $ で表示する.
" set list
" Listモードに使われる文字を設定する "
"set listchars=tab:\ \ ,trail:-,eol:\
" 勝手に作られる系のファイルを一箇所にまとめる
set directory=~/.vim/swp
set undodir=~/.vim/undo
" stop hiding json quote
"set conceallevel=0
""" }}}

""" Util {{{
" augroup AutoDeleteTailSpace
"   autocmd!
"   autocmd BufWritePre * :%s/\s\+$//ge
" augroup END

" 一定時間カーソルを移動しないとカーソルラインを表示（ただし，ウィンドウ移動時
" はなぜか切り替わらない
" http://d.hatena.ne.jp/thinca/20090530/1243615055
augroup AutoCursorLine
  autocmd!
  autocmd CursorMoved,CursorMovedI,WinLeave * setlocal nocursorline
  autocmd CursorHold,CursorHoldI,WinEnter * setlocal cursorline
augroup END

" imsertモードから抜けるときにIMをOFFにする（GUI(MacVim)は自動的にやってくれる
" iminsert = 2にすると，insertモードに戻ったときに自動的にIMの状態が復元される
if !has("gui-running")
  inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

" ファイルを開いたときに, カレントディレクトリを編集中のファイルディレクトリに変更
augroup grlcd
  autocmd!
  autocmd BufEnter * lcd %:p:h
augroup END

" :vimgrepでの検索後, QuickFixウィンドウを開く
augroup greopen
  autocmd!
  autocmd QuickfixCmdPost vimgrep cw
augroup END

" vimrcのリロード
command! ReloadVimrc source $MYVIMRC

" カーソル位置の復元
autocmd MyAutocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
" Hack #202: 自動的にディレクトリを作成する
" http://vim-users.jp/2011/02/hack202/
autocmd MyAutocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
           \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
     " call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
     call mkdir(a:dir, 'p')
  endif
endfunction

" ファイルタイプを書き込み時に自動判別
autocmd MyAutocmd BufWritePost
\ * if &l:filetype ==# '' || exists('b:ftdetect')
\ |   unlet! b:ftdetect
\ |   filetype detect
\ | endif
" git commit message のときは折りたたまない(diff で中途半端な折りたたみになりがち)
autocmd MyAutocmd FileType gitcommit setlocal nofoldenable

" git のルートディレクトリを開く
function! s:git_root_dir()
  if (system('git rev-parse --is-inside-work-tree') == "true\n")
    let s:path = system('git rev-parse --show-cdup')
    return strpart(s:path, 0, strlen(s:path)-1) " 末尾改行削除
  else
    echoerr 'current directory is outside git working tree'
  endif
endfunction

" 行末のスペースをハイライト
"http://d.hatena.ne.jp/mickey24/20120808/vim_highlight_trailing_spaces
augroup HighlightTrailingSpaces
  autocmd!
  autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
  autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

" 挿入モードとノーマルモードでステータスラインの色変更
autocmd MyAutocmd InsertEnter * hi StatusLine guifg=DarkBlue guibg=DarkYellow gui=none ctermfg=Blue ctermfg=Yellow cterm=none
autocmd MyAutocmd InsertLeave * hi StatusLine guifg=DarkBlue guibg=DarkGray   gui=none ctermfg=Blue ctermbg=DarkGray cterm=none
""" }}}

" tmp memo
command! Memo edit ~/Dropbox/memo/tmp.txt
command! Work edit ~/Dropbox/memo/works.txt

" git-browse-remote
" http://motemen.hatenablog.com/entry/2014/06/05/released-git-browse-remote-0-1-0
command! -nargs=* -range GB !git browse-remote --rev -L<line1>,<line2> <f-args> -- %

""" Keymap {{{
" :w1 と打ってしまうくせ防止
cabbrev q1 q!
cabbrev w1 w!
cabbrev wq1 wq!
" insertモードから抜ける
inoremap <silent> jj <ESC>
inoremap <silent> <C-j> j

" ; と : をスワップ
" inoremap : ;
" inoremap ; :
" nnoremap : ;
" nnoremap ; :
" vnoremap : ;
" vnoremap ; :

" insertモードでもquit
inoremap <C-q><C-q> <Esc>:wq<CR>
" insertモードでもsave
inoremap <C-w><C-w> <Esc>:w<Insert><CR>

" insertモードでC-s -> Save, C-q -> Quit
inoremap <C-s> <Esc>:w<CR>
inoremap <C-q> <Esc>:q<CR>

"Esc->Escで検索結果とエラーハイライトをクリア
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>

" 賢く行頭・非空白行頭・行末の移動
nnoremap <silent>0 :<C-u>call <SID>smart_move('g^')<CR>
vnoremap <silent>0 :<C-u>call <SID>smart_move('g^')<CR>
nnoremap <silent>^ :<C-u>call <SID>smart_move('g0')<CR>
vnoremap <silent>^ :<C-u>call <SID>smart_move('g0')<CR>
nnoremap <silent>- :<C-u>call <SID>smart_move('g$')<CR>
vnoremap <silent>- :<C-u>call <SID>smart_move('g$')<CR>
" Visualモード時にvで行末まで選択する
vnoremap v $h

" 表示行単位で行移動する
nmap j gj
nmap k gk
vmap j gj
vmap k gk

" insertモードでのカーソル移動 ポップアップウィンドウがでないように
inoremap <C-e> <END>
vnoremap <C-e> <END>
cnoremap <C-e> <END>
inoremap <C-a> <HOME>
vnoremap <C-a> <HOME>
cnoremap <C-a> <HOME>
inoremap <silent><expr><C-j> pumvisible() ? "\<C-y>\<Down>" : "\<Down>"
inoremap <silent><expr><C-k> pumvisible() ? "\<C-y>\<Up>" : "\<Up>"
inoremap <silent><expr><C-h> pumvisible() ? "\<C-y>\<Left>" : "\<Left>"
inoremap <silent><expr><C-l> pumvisible() ? "\<C-y>\<Right>" : "\<Right>"
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
" カーソル前の文字削除
inoremap <silent> <C-h> <C-g>u<C-h>
cnoremap <silent> <C-h> <C-g>u<C-h>
" カーソル後の文字削除
inoremap <silent> <C-d> <Del>
cnoremap <silent> <C-d> <Del>
" 引用符, 括弧の設定
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap () ()<Left>
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap <> <><Left>
inoremap []5 [%  %]<Left><Left><Left>
inoremap {}5 {%  %}<Left><Left><Left>
inoremap <>5 <%  %><Left><Left><Left>

" 行末までヤンク
nnoremap Y y$

" 空行挿入
nnoremap O :<C-u>call append(expand('.'), '')<CR>j

"ヘルプ表示
nnoremap <Leader>h :<C-u>vert to help<Space>

" CTRL-hjklでウィンドウ移動
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" ウィンドウ分割時にウィンドウサイズを調節
nnoremap <silent> <S-Left>  :5wincmd <<CR>
nnoremap <silent> <S-Right> :5wincmd ><CR>
nnoremap <silent> <S-Up>    :5wincmd -<CR>
nnoremap <silent> <S-Down>  :5wincmd +<CR>

" 検索後画面の中心に移動
nnoremap n nzvzz
nnoremap N Nzvzz
nnoremap * *zvzz
nnoremap # *zvzz

"バッファ切り替え
nnoremap <silent><C-n>   :<C-u>bnext<CR>
nnoremap <silent><C-p>   :<C-u>bprevious<CR>

" タブの設定
nnoremap ge :<C-u>tabedit<Space>
nnoremap gn :<C-u>tabnew<CR>

" 初回のみ a:cmd の動きをして，それ以降は行内をローテートする
let s:smart_line_pos = -1
function! s:smart_move(cmd)
  let line = line('.')
  if s:smart_line_pos == line . a:cmd
    call <SID>rotate_in_line()
  else
    execute "normal! " . a:cmd
    " 最後に移動した行とマッピングを保持
    let s:smart_line_pos = line . a:cmd
  endif
endfunction

" 行頭 → 非空白行頭 → 行 をローテートする by Linda_pp
" http://qiita.com/items/ee4bf64b1fe2c0a32cbd#comment-e2aafa1f4e60ae49a730
function! s:rotate_in_line()
  let c = col('.')

  if c == 1
    let cmd = '^'
  else
    let cmd = '$'
  endif

  execute "normal! ".cmd

  if c == col('.')
    if cmd == '^'
      normal! $
    else
      normal! 0
    endif
  endif
endfunction
" , に割り当てる
nnoremap <silent>, :<C-u>call <SID>rotate_in_line()<CR>

""" }}}

""" FileType {{{
set autoindent   " 自動でインデント
set cindent      " Cプログラムファイルの自動インデントを始める．これがあれば smartindent 要らない．
" softtabstopはTabキー押し下げ時の挿入される空白の量，0の場合はtabstopと同じ，BSにも影響する
set tabstop=2 shiftwidth=2 softtabstop=0

"ファイルタイプの検索を有効にする
filetype plugin on
"そのファイルタイプにあわせたインデントを利用する
filetype indent on

augroup FileTypeDetect
  autocmd!
  autocmd BufNewFile,BufRead cpanfile set filetype=cpanfile
  autocmd BufNewFile,BufRead cpanfile set syntax=perl.cpanfile
  autocmd BufNewFile,BufRead ELBfile,EIPfile,Groupfile,IAMfile,Routefile setf ruby
  autocmd BufNewFile,BufRead *.PL,*.t,*.psgi,*.perldb,cpanfile setf perl
  autocmd BufNewFile,BufRead *.tx setfiletype xslate " from vim-xslate
  autocmd BufNewFile,BufRead Capfile,Thorfile set filetype=ruby
  autocmd BufNewFile,BufRead *.html if search('^; ') > 0 | set filetype=xslate | endif
  autocmd BufNewFile,BufRead *.hpp,*.cl setf cpp
  autocmd BufNewFile,BufRead *.cu,*.hcu setf cuda
  autocmd BufNewFile,BufRead *.aj setf java
  autocmd BufNewFile,BufRead *.jspx setf xhtml
  autocmd BufNewFile,BufRead *.tex,*.latex,*.sty,*.dtx,*.ltx,*.bbl setf tex
  autocmd BufNewFile,BufRead *.tt,*.tt2 setf tt2html
  autocmd BufNewFile,BufRead *.html setf tt2html
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} setf markdown
  autocmd BufNewFile,BufRead *.less setf less
  autocmd BufNewFile,BufRead *.coffee setf coffee
  autocmd BufNewFile,BufRead *.erb set filetype=eruby.html
  autocmd BufNewFile,BufRead */nginx.conf set filetype=nginx
  autocmd BufNewFile,BufRead *.nginx.conf set filetype=nginx
augroup END

augroup IndentGroup
  autocmd!
  " インデント幅4
  " setlocal sw=4 sts=4 ts=4 et
  autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
  autocmd FileType c          setlocal sw=4 sts=4 ts=4 et
  autocmd FileType cuda       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType cpp        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType cs         setlocal sw=4 sts=4 ts=4 et
  autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType diff       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType eruby      setlocal sw=2 sts=2 ts=2 et
  autocmd FileType go         setlocal sw=8 sts=8 ts=8 et
  autocmd FileType groovy     setlocal sw=4 sts=4 ts=4 et
  autocmd FileType haml       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType hpp        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType javascript setlocal sw=4 sts=4 ts=4 et
  autocmd FileType markdown   setlocal sw=2 sts=2 ts=2 et
  autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType python     setlocal sw=4 sts=4 ts=4 et
  autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType rust       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType scala      setlocal sw=2 sts=2 ts=2 et
  autocmd FileType sh         setlocal sw=4 sts=4 ts=4 et
  autocmd FileType sql        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType terraform  setlocal sw=4 sts=4 ts=4 et
  autocmd FileType tex        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType tt2        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType tt2html    setlocal sw=2 sts=2 ts=2 et
  autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType xhtml      setlocal sw=4 sts=4 ts=4 et
  autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType zsh        setlocal sw=2 sts=2 ts=2 et

  autocmd FileType perl,cgi   compiler perl
  autocmd FileType perl,cgi   nmap <buffer>,pt <ESC>:%! perltidy<CR> " ソースコード全体を整形
  autocmd FileType perl,cgi   nmap <buffer>,ptv <ESC>:%'<, '>! perltidy<CR> " 選択された部分のソースコードを整形
  autocmd FileType python     setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
  autocmd FileType ruby       compiler ruby
  autocmd FileType go         setlocal noexpandtab
  autocmd FileType tex        setlocal spelllang=en,cjk
augroup END

" http://d.hatena.ne.jp/WK6/20120606/1338993826
autocmd FileType text setlocal textwidth=0

"" ファイル形式毎にテンプレートを設定 {{{
augroup templates
  autocmd!
  " autocmd BufNewFile *.pl 0r $HOME/.vim/templates/template.pl
  " autocmd BufNewFile *.pm 0r $HOME/.vim/templates/template.pl
  autocmd BufNewFile *.rb 0r $HOME/.vim/templates/template.rb
  autocmd BufNewFile *.py 0r $HOME/.vim/templates/template.py
augroup END
"" }}}

"" +perl, +python, +ruby  for MacVim {{{
if has('gui_macvim') && has('kaoriya')
  let s:ruby_libdir = system("ruby -rrbconfig -e 'print Config::CONFIG[\"libdir\"]'")
  let s:ruby_libruby = s:ruby_libdir . '/libruby.dylib'
  if filereadable(s:ruby_libruby)
    let $RUBY_DLL = s:ruby_libruby
  endif
endif
let $PERL_DLL = "/System/Library/Perl/5.12/darwin-thread-multi-2level/CORE/libperl.dylib"
let $PYTHON_DLL = "$HOME/.pythonz/CPython-2.7.3/lib/libpython2.7.dylib"
"" }}}

" Go {{{
if $GOROOT != ''
  set rtp+=$GOROOT/misc/vim
endif
" }}}
""" }}}

""" Plugins {{{
" neobundle.vim が無ければインストールする
if ! isdirectory(expand('~/.vim/bundle'))
    echon "Installing neobundle.vim..."
    silent call mkdir(expand('~/.vim/bundle'), 'p')
    silent !git clone https://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
    echo "done."
    if v:shell_error
        echoerr "neobundle.vim installation has failed!"
        finish
    endif
endif

if has('vim_starting')
    set rtp+=~/.vim/bundle/neobundle.vim/
endif

let s:meet_neocomplete_requirements = has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))

call neobundle#begin(expand('~/.vim/bundle'))

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc', {
            \ 'build' : {
            \       'mac'     : 'make -f make_mac.mak',
            \       'unix'    : 'make -f make_unix.mak',
            \   }
            \ }
NeoBundle 'Shougo/vimfiler'
NeoBundle 'Shougo/vinarise'
NeoBundle 'Shougo/echodoc'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'osyo-manga/unite-fold'
NeoBundle 'osyo-manga/unite-quickfix'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'tsukkee/unite-tag'
NeoBundle 'jceb/vim-hier'
NeoBundle 'Lokaltog/vim-powerline'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'hewes/unite-gtags'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'rhysd/vim-operator-surround'
NeoBundle "kana/vim-textobj-user"
NeoBundle 'osyo-manga/vim-textobj-multiblock'
NeoBundle 'osyo-manga/vim-operator-search'
NeoBundle 'rhysd/quickrun-unite-quickfix-outputter'
NeoBundle 'osyo-manga/shabadou.vim'
" NeoBundle 'osyo-manga/vim-watchdogs'
NeoBundle 'rhysd/unite-zsh-cdr.vim'
NeoBundle 'y-uuki/perl-local-lib-path.vim'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'osyo-manga/vim-over'
NeoBundle 'mhinz/vim-signify'
NeoBundle 'rhysd/conflict-marker.vim'
NeoBundle 'rhysd/clever-f.vim'
NeoBundle 'fatih/vim-go'
NeoBundle 'moznion/github-commit-comment.vim'
NeoBundle 'honza/dockerfile.vim'
NeoBundle 'glidenote/memolist.vim'
NeoBundle 'glidenote/serverspec-snippets'
NeoBundle 'sorah/unite-ghq'
NeoBundle 'cohama/agit.vim'
NeoBundle 'chase/vim-ansible-yaml'
" NeoBundle 'godlygeek/tabular'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
NeoBundle 'rcmdnk/vim-markdown'
NeoBundle 'markcornick/vim-terraform'
NeoBundle 'vim-scripts/VOoM'
" NeoBundle 'vim-scripts/vim-auto-save'
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'racer-rust/vim-racer'
NeoBundle 'vim-scripts/nginx.vim'
NeoBundle 'kmnk/vim-unite-giti'
NeoBundle 'rhysd/committia.vim'
NeoBundle 'vim-scripts/ZoomWin'

if s:meet_neocomplete_requirements
    NeoBundle 'Shougo/neocomplete.vim'
else
    NeoBundle 'Shougo/neocomplcache.vim'
endif

" colorscheme
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'tomasr/molokai'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'telamon/vim-color-github'
NeoBundle 'earendel'
NeoBundle 'rdark'
NeoBundle 'rhysd/wallaby.vim'

NeoBundleLazy 'Shougo/vimshell', {
            \ 'autoload' : {
            \     'commands' : ['VimShell', 'VimShellSendString', 'VimShellCurrentDir'],
            \     }
            \ }
NeoBundleLazy 'y-uuki/unite-perl-module.vim', {
            \ 'depends' : [ 'Shougo/unite.vim' ],
            \ 'autoload' : {'filetypes' : 'perl'}
            \ }
NeoBundleLazy 'vim-perl/vim-perl', {
            \ 'autoload' : {'filetypes' : 'perl'}
            \ }
NeoBundleLazy 'moznion/vim-cpanfile', {
            \ 'autoload' : {'filetypes' : 'perl'}
            \ }
NeoBundleLazy 'mattn/perlvalidate-vim.git', {
            \ 'autoload' : {'filetypes' : 'perl'}
            \ }
NeoBundleLazy 'vim-ruby/vim-ruby', {
            \ 'autoload' : {'filetypes' : 'ruby'}
            \ }
NeoBundleLazy 'rhysd/unite-ruby-require.vim', {
            \ 'depends' : [ 'Shougo/unite.vim' ],
            \ 'autoload' : {'filetypes' : 'ruby'}
            \ }
NeoBundleLazy 'motemen/xslate-vim', {
            \ 'autoload' : {'filetypes' : 'xslate'}
            \ }
NeoBundleLazy 'kchmck/vim-coffee-script', {
            \ 'autoload' : {'filetypes' : 'coffee'}
            \ }
NeoBundleLazy 'groenewege/vim-less', {
            \ 'autoload' : {'filetypes' : 'less'}
            \ }
NeoBundleLazy 'tpope/vim-haml.git', {
            \ 'autoload' : {'filetypes' : 'haml'}
            \ }
NeoBundleLazy 'zaiste/tmux.vim', {
            \ 'autoload' : {'filetypes' : 'tmux'}
            \ }
NeoBundleLazy 'micheljansen/vim-latex', {
            \ 'autoload' : {'filetypes' : 'latex'}
            \ }
NeoBundleLazy 'derekwyatt/vim-scala', {
            \ 'autoload' : {'filetypes' : 'scala'}
            \ }
NeoBundleLazy 'kana/vim-operator-replace', {
            \ 'autoload' : {
            \     'mappings' : '<Plug>(operator-replace)'
            \     }
            \ }
NeoBundleLazy 'roalddevries/yaml.vim', {
            \ 'autoload' : {'filetypes' : 'yaml'}
            \ }
NeoBundleLazy 'corylanou/vim-present', {
            \ 'autoload' : {'filetypes' : 'present'}
            \ }
NeoBundleLazy 'majutsushi/tagbar', {
            \ 'autoload' : {'filetypes' : 'go'}
            \ }
NeoBundleLazy 'sudo.vim'
NeoBundleLazy 'lambdalisue/unite-grep-vcs', {
            \ 'autoload': {
            \    'unite_sources': ['grep/git', 'grep/hg'],
            \ }}

NeoBundleCheck
NeoBundleSaveCache

"if neobundle#has_cache()
"    NeoBundleLoadCache
"else
"    call s:cache_bundles()
"endif

call neobundle#end()
filetype plugin indent on     " required!

autocmd MyAutocmd BufWritePost *vimrc,*gvimrc NeoBundleClearCache

" ReadOnly のファイルを編集しようとしたときに sudo.vim を遅延読み込み
autocmd MyAutocmd FileChangedRO * NeoBundleSource sudo.vim
autocmd MyAutocmd FileChangedRO * execute "command! W SudoWrite" expand('%')
""" }}}


" カラースキーム {{{
" シンタックスハイライト
syntax enable
if !has('gui_running')
    if &t_Co < 256
        colorscheme default
    else
        try
            colorscheme wallaby
        catch
            colorscheme desert
        endtry
    endif
endif

" seoul256 バックグラウンドカラーの明るさ
let g:seoul256_background = 233
" }}}

"" neocomplcache {{{

if s:meet_neocomplete_requirements
    " neocomplete用設定
    "vim起動時に有効化
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_ignore_case = 1
    "smart_caseを有効にする．大文字が入力されるまで大文字小文字の区別をなくす
    let g:neocomplete#enable_smart_case = 1
    " 日本語を収集しないようにする
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns._ = '\h\w*'
    let g:neocomplete#enable_camel_case_completion = 1
    let g:neocomplete#enable_underbar_completion = 1

    " vim起動時に有効化
    let g:neocomplete#enable_at_startup = 1
    " smart_caseを有効にする．大文字が入力されるまで大文字小文字の区別をなくす
    let g:neocomplete#enable_smart_case = 1
    " _を区切りとした補完を有効にする
    let g:neocomplete#enable_underbar_completion = 1
    " シンタックスをキャッシュするときの最小文字長を3に
    let g:neocomplete#min_syntax_length = 3
    " リスト表示
    let g:neocomplete#max_list = 300
    let g:neocomplete#max_keyword_width = 20
    " 辞書定義
    let g:neocomplete#dictionary_filetype_lists = {
                \ 'default' : '',
                \ 'vimshell' : expand('~/.vimshell/command-history'),
                \ 'vim' : '~/.vim/dict/perl_functions.dict',
                \ 'cpanfile' : '~/.vim/bundle/vim-cpanfile/dict/cpanfile.dict'
                \ }
    let g:neocomplete#ctags_arguments_list = {
      \ 'perl' : '-R -h ".pm"'
      \ }
    " 補完の区切り文字
    if !exists('g:neocomplete#delimiter_patterns')
        let g:neocomplete#delimiter_patterns = {}
    endif
    let g:neocomplete#delimiter_patterns.vim = ['#']
    let g:neocomplete#delimiter_patterns.ruby = ['::']
    let g:neocomplete#delimiter_patterns.perl = ['::']
    "リスト表示
    let g:neocomplete#max_list = 300

    "neocompleteのマッピング
    inoremap <expr><C-g> neocomplete#undo_completion()
    inoremap <expr><C-s> neocomplete#complete_common_string()
    " <Tab>: completion
    inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    "<C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplete#cancel_popup()
else
    " neocomplcache用設定
    let g:neocomplcache_enable_at_startup = 1
    let g:neocomplcache_enable_ignore_case = 1
    let g:neocomplcache_enable_smart_case = 1
    if !exists('g:neocomplcache_keyword_patterns')
        let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns._ = '\h\w*'
    let g:neocomplcache_enable_camel_case_completion = 1
    let g:neocomplcache_enable_underbar_completion = 1

    " vim起動時に有効化
    let g:neocomplcache_enable_at_startup = 1
    " smart_caseを有効にする．大文字が入力されるまで大文字小文字の区別をなくす
    let g:neocomplcache_enable_smart_case = 1
    " _を区切りとした補完を有効にする
    let g:neocomplcache_enable_underbar_completion = 1
    " シンタックスをキャッシュするときの最小文字長を3に
    let g:neocomplcache_min_syntax_length = 3
    " リスト表示
    let g:neocomplcache_max_list = 300
    let g:neocomplcache_max_keyword_width = 20
    " 辞書定義
    let g:neocomplcache_dictionary_filetype_lists = {
                \ 'default' : '',
                \ 'vimshell' : expand('~/.vimshell/command-history'),
                \ 'vim' : '~/.vim/dict/perl_functions.dict',
                \ 'cpanfile' : '~/.vim/bundle/vim-cpanfile/dict/cpanfile.dict'
                \ }
    let g:neocomplcache_ctags_arguments_list = {
      \ 'perl' : '-R -h ".pm"'
      \ }
    " 補完の区切り文字
    if !exists('g:neocomplcache_delimiter_patterns')
        let g:neocomplcache_delimiter_patterns = {}
    endif
    let g:neocomplcache_delimiter_patterns.vim = ['#']
    let g:neocomplcache_delimiter_patterns.ruby = ['::']
    let g:neocomplcache_delimiter_patterns.perl = []
    "neocomplcacheのマッピング
    inoremap <expr><C-g> neocomplcache#undo_completion()
    inoremap <expr><C-s> neocomplcache#complete_common_string()
    " <CR>: close popup and save indent.
    " <Tab>: completion
    inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
endif

" AutoComplPopを無効にする
let g:acp_enableAtStartup = 0

if !has("gui_running")
  " CUIのvimでの補完リストの色を調節する
  highlight Pmenu ctermbg=8
endif

" Enable omni completion.
augroup NeocomplcacheOmniFunc
    autocmd!
    autocmd FileType python     setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType html       setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType css        setlocal omnifunc=csscomplete#CompleteCss
    autocmd FileType xml        setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType php        setlocal omnifunc=phpcomplete#CompletePHP
    autocmd FileType c          setlocal omnifunc=ccomplete#Complete
    " autocmd FileType ruby set omnifunc=rubycomplete#Complete
augroup END
"" }}}

"" neosnippet {{{
" http://kazuph.hateblo.jp/entry/2012/11/28/105633
imap <C-b> <Plug>(neosnippet_expand_or_jump)
smap <C-b> <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
"" }}}
" 自作スニペット {{{
let g:neosnippet#snippets_directory = [
      \'~/.vim/snippets/snippets',
      \'~/.vim/bundle/serverspec-snippets',
      \]
"" }}}

"" unite.vim {{{
let g:unite_prompt = '> '
" insertモードをデフォルトに
let g:unite_enable_start_insert = 1
" 無指定にすることで高速化
let g:unite_source_file_mru_filename_format = ''
" most recently used のリストサイズ
let g:unite_source_file_mru_limit = 100
" Unite起動時のウィンドウ分割
let g:unite_split_rule = 'rightbelow'
" 使わないデフォルト Unite ソースをロードしない
let g:loaded_unite_source_bookmark = 1
let g:loaded_unite_source_window = 1
" unite-grep で使うコマンド
let g:unite_source_grep_default_opts = "-Hn --color=never"
" the silver searcher を unite-grep のバックエンドにする
if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nocolor --nogroup --column'
    let g:unite_source_grep_recursive_opt = ''
endif

" unite のデフォルトアクション
call unite#custom#default_action('directory' , 'vimfiler')

" unite.vim カスタムアクション
function! s:define_unite_actions()
    " Git リポジトリのすべてのファイルを開くアクション {{{
    let git_repo = { 'description' : 'all file in git repository' }
    function! git_repo.func(candidate)
        if(unite#util#system('git rev-parse --is-inside-work-tree') ==# "true\n" )
            execute 'args'
                    \ join( filter(split(system('git ls-files `git rev-parse --show-cdup`'), '\n')
                            \ , 'empty(v:val) || isdirectory(v:val) || filereadable(v:val)') )
        else
            echoerr 'Not a git repository!'
        endif
    endfunction

    call unite#custom_action('file', 'git_repo_files', git_repo)
    " }}}

    " ファイルなら開き，ディレクトリなら VimFiler に渡す {{{
    let open_or_vimfiler = {
                \ 'description' : 'open a file or open a directory with vimfiler',
                \ 'is_selectable' : 1,
                \ }
    function! open_or_vimfiler.func(candidates)
        for candidate in a:candidates
            if candidate.kind ==# 'directory'
                execute 'VimFiler' candidate.action__path
                return
            endif
        endfor
        execute 'args' join(map(a:candidates, 'v:val.action__path'), ' ')
    endfunction
    call unite#custom_action('file', 'open_or_vimfiler', open_or_vimfiler)
    "}}}

    " Finder for Mac
    if has('mac')
        let finder = { 'description' : 'open with Finder.app' }
        function! finder.func(candidate)
            if a:candidate.kind ==# 'directory'
                call system('open -a Finder '.a:candidate.action__path)
            endif
        endfunction
        call unite#custom_action('directory', 'finder', finder)
    endif

    " load once
    autocmd! UniteCustomActions
endfunction

" カスタムアクションを遅延定義
augroup UniteCustomActions
    autocmd!
    autocmd FileType unite,vimfiler call <SID>define_unite_actions()
augroup END

nnoremap  [unite] <Nop>
nmap      <Space> [unite]

"バッファを開いた時のパスを起点としたファイル検索
nnoremap <silent> [unite]ff :<C-u>UniteWithBufferDir -buffer-name=files file -vertical<CR>
" 最近使用したファイル一覧
nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
" ファイル一覧
nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files file<CR>
" バッファ一覧
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
" Unite ソース一覧
nnoremap <silent> [unite]s :<C-u>Unite source -vertical<CR>
" 常用セット
nnoremap <silent> [unite]u :<C-u>Unite -no-split buffer file_mru<CR>
" 現在のバッファのカレントディレクトリからファイル一覧
nnoremap <silent> [unite]d :<C-u>UniteWithBufferDir -no-split file<CR>
"バッファを開いた時のパスを起点としたファイル検索
nnoremap <silent>[unite]<Space> :<C-u>UniteWithBufferDir -buffer-name=files file -vertical<CR>
" grep検索
nnoremap <silent> [unite]G :<C-u>Unite -no-start-insert grep<CR>
" Uniteバッファの復元
nnoremap <silent> [unite]r :<C-u>UniteResume<CR>
" バッファ全体
nnoremap <silent> [unite]L :<C-u>Unite line<CR>
" ブックマーク一覧
nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
" ブックマークに追加
nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>
" スニペット候補表示
nnoremap <silent> [unite]s <Plug>(neocomplcache_start_unite_snippet)
" Git のルートディレクトリを開く
" nnoremap <silent><expr>[unite]fg  :<C-u>Unite file -input=".fnamemodify(<SID>git_root_dir(),":p")
" プロジェクトのファイル一覧
nnoremap <silent>[unite]p         :<C-u>Unite file_rec:! file/new<CR>
" 検索に unite-lines を使う
nnoremap <silent><expr> [unite]/ line('$') > 5000 ?
            \ ":\<C-u>Unite -buffer-name=search -no-split -start-insert line/fast\<CR>" :
            \ ":\<C-u>Unite -buffer-name=search -start-insert line\<CR>"
" zsh の cdr コマンド
nnoremap <silent>[unite]z :<C-u>Unite zsh-cdr<CR>
" unite-ghq + cdr
nnoremap <silent>[unite]q :<C-u>Unite -start-insert -default-action=vimfiler zsh-cdr ghq directory_mru<CR>
" unite-grep-vcs
nnoremap <silent> [unite]gg :<C-u>Unite grep/git:. -buffer-name=search-buffer<CR>

" project検索
call unite#custom#source('file_rec/async', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\tar.gz\)$')
let g:unite_source_rec_max_cache_files = 500000
nnoremap <silent> [unite]v :<C-u>Unite -start-insert file_rec/async:!<CR>

"" unite-perl-module
" Perl local lib modules
autocmd MyAutocmd FileType perl nnoremap <buffer>[unite]pl :<C-u>Unite perl/local<CR>
" Perl global lib modules
autocmd MyAutocmd FileType perl nnoremap <buffer>[unite]pg :<C-u>Unite perl/global<CR>

"" unite-gtags
nnoremap <silent> [unite]gc :<C-u>Unite gtags/context<CR>
nnoremap <silent> [unite]gr :<C-u>Unite gtags/ref<CR>
nnoremap <silent> [unite]gd :<C-u>Unite gtags/def<CR>
nnoremap <silent> [unite]gt :<C-u>Unite gtags/gtags<SPACE>
nnoremap <silent> [unite]gcc :<C-u>Unite gtags/completion<CR>

"" vim-unite-giti
nmap <Leader>gd <SID>(git-diff-cached)
nmap <Leader>gD <SID>(git-diff)
nmap <Leader>gf <SID>(git-fetch-now)
nmap <Leader>gF <SID>(git-fetch)
nmap <Leader>gp <SID>(git-push-now)
nmap <Leader>gP <SID>(git-pull-now)
nmap <Leader>gl <SID>(git-log-line)
nmap <Leader>gL <SID>(git-log)

nmap <silent> [unite]gg  <SID>(giti-grep)
nmap <silent> [unite]gst <SID>(git-status)
nmap <silent> [unite]gb  <SID>(git-branch)
nmap <silent> [unite]gB  <SID>(git-branch_all)
nmap <silent> [unite]gc  <SID>(git-config)
nmap <silent> [unite]gl  <SID>(git-log)
nmap <silent> [unite]gL  <SID>(git-log-this-file)

call unite#custom#default_action("giti/status", "add")

if globpath(&rtp, 'plugin/giti.vim') != ''
  let g:giti_log_default_line_count = 100
  nnoremap <expr><silent> <SID>(git-diff)        ':<C-u>GitiDiff ' . expand('%:p') . '<CR>'
  nnoremap <expr><silent> <SID>(git-diff-cached) ':<C-u>GitiDiffCached ' . expand('%:p') .  '<CR>'
  nnoremap       <silent> <SID>(git-fetch-now)    :<C-u>GitiFetch<CR>
  nnoremap       <silent> <SID>(git-fetch)        :<C-u>GitiFetch
  nnoremap <expr><silent> <SID>(git-push-now)    ':<C-u>GitiPushWithSettingUpstream origin ' . giti#branch#current_name() . '<CR>'
  nnoremap       <silent> <SID>(git-push)         :<C-u>GitiPush
  nnoremap       <silent> <SID>(git-pull-now)     :<C-u>GitiPull<CR>
  nnoremap       <silent> <SID>(git-pull)         :<C-u>GitiPull
  nnoremap       <silent> <SID>(git-log-line)     :<C-u>GitiLogLine ' . expand('%:p') . '<CR>'
  nnoremap       <silent> <SID>(git-log)          :<C-u>GitiLog ' . expand('%:p') . '<CR>'
  nnoremap <silent> <SID>(giti-sources)   :<C-u>Unite giti<CR>
  nnoremap <silent> <SID>(git-status)     :<C-u>Unite giti/status<CR>
  nnoremap <silent> <SID>(git-branch)     :<C-u>Unite giti/branch<CR>
  nnoremap <silent> <SID>(git-branch_all) :<C-u>Unite giti/branch_all<CR>
  nnoremap <silent> <SID>(git-config)     :<C-u>Unite giti/config<CR>
  nnoremap <silent> <SID>(git-log)        :<C-u>Unite giti/log<CR>
  nnoremap <silent> <SID>(giti-grep)      :<C-u>Unite giti/grep<CR>
  nnoremap <silent><expr> <SID>(git-log-this-file) ':<C-u>Unite giti/log:' . expand('%:p') . '<CR>'
endif

"" unite-qfixhowm
" nnoremap <silent> [unite]mm :<C-u>Unite qfixhowm/new qfixhowm -hide-source-names<CR>

augroup UniteMapping
  autocmd!
  " insertモード時はC-gでいつでもバッファを閉じられる（絞り込み欄が空の時はC-hでもOK）
  autocmd FileType unite imap <buffer><C-g> <Plug>(unite_exit)
  " <Space> だと待ち時間が発生してしまうので <Space><Space> を割り当て
  autocmd FileType unite nmap <buffer><Space><Space> <Plug>(unite_toggle_mark_current_candidate)
  " q だと待ち時間が発生してしまうので
  autocmd FileType unite nmap <buffer><C-g> <Plug>(unite_exit)
  " jjでインサートモードを抜ける
  autocmd FileType unite imap <buffer> jj <Plug>(unite_insert_leave)
  " 直前のパス削除
  autocmd FileType unite imap <buffer><C-w> <Plug>(unite_delete_backward_path)
  autocmd FileType unite nmap <buffer>h <Plug>(unite_delete_backward_path)
  " ファイル上にカーソルがある時，pでプレビューを見る
  autocmd FileType unite inoremap <buffer><expr>p unite#smart_map("p", unite#do_action('preview'))
  " C-xでクイックマッチ
  autocmd FileType unite imap <buffer><C-x> <Plug>(unite_quick_match_default_action)
  " lでデフォルトアクションを実行
  autocmd FileType unite nmap <buffer>l <Plug>(unite_do_default_action)
  autocmd FileType unite imap <buffer><expr>l unite#smart_map("l", unite#do_action(unite#get_current_unite().context.default_action))
  " tでtabedit
  autocmd FileType unite nnoremap <buffer><expr> t unite#smart_map('t', unite#do_action('tabopen'))
  autocmd FileType uniti inoremap <buffer><expr> t unite#smart_map('t', unite#do_action('tabopen'))
  " sでsplit
  autocmd FileType unite nnoremap <buffer><expr> s unite#smart_map('s', unite#do_action('split'))
  autocmd FileType unite inoremap <buffer><expr> s unite#smart_map('s', unite#do_action('split'))
  " vでsplit
  autocmd FileType unite nnoremap <buffer><expr> v unite#smart_map('v', unite#do_action('vsplit'))
  autocmd FileType unite inoremap <buffer><expr> v unite#smart_map('v', unite#do_action('vsplit'))
  " fでvimfiler
  autocmd FileType unite nnoremap <buffer><expr> f unite#smart_map('f', unite#do_action('vimfiler'))
  autocmd FileType unite inoremap <buffer><expr> f unite#smart_map('f', unite#do_action('vimfiler'))
augroup END
"" }}}

"" VimFiler {{{
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_split_command = 'vertical rightbelow vsplit'
let g:vimfiler_execute_file_list = { 'c' : 'vim', 'h' : 'vim', 'cpp' : 'vim', 'hpp' : 'vim', 'cc' : 'vim', 'rb' : 'vim', 'pl' : 'vim', 'pm' : 'vim', 'txt' : 'vim', 'pdf' : 'open', 'vim' : 'vim' }
" let g:vimfiler_edit_action = 'vsplit'
let g:vimfiler_directory_display_top = 1
let g:vimfiler_enable_auto_cd = 1

augroup VimFilerMapping
  autocmd!
  autocmd FileType vimfiler nmap <buffer><silent><expr> e vimfiler#smart_cursor_map(
        \   "\<Plug>(vimfiler_cd_file)",
        \   "\<Plug>(vimfiler_edit_file)")
  autocmd FileType vimfiler nmap <buffer><silent><expr><CR> vimfiler#smart_cursor_map(
        \   "\<Plug>(vimfiler_expand_tree)",
        \   "\<Plug>(vimfiler_edit_file)")
  autocmd FileType vimfiler nmap <buffer><silent>x <Plug>(vimfiler_hide)
augroup END

""" VimFilerTree {{{
" http://qiita.com/shiena/items/870ac0f1db8e9a8672a7
command! VimFilerTree call VimFilerTree()
function! VimFilerTree()
    exec ':VimFiler -buffer-name=explorer -split -simple -winwidth=25 -toggle -no-quit'
    wincmd t
    setl winfixwidth
endfunction
let g:vim_filer_tree_my_action = {'is_selectable' : 1}
function! g:vim_filer_tree_my_action.func(candidates)
    wincmd p
    exec 'split '. a:candidates[0].action__path
endfunction
call unite#custom_action('file', 'my_split', g:vim_filer_tree_my_action)

let g:vim_filer_tree_my_action = {'is_selectable' : 1}
function! g:vim_filer_tree_my_action.func(candidates)
    wincmd p
    exec 'vsplit '. a:candidates[0].action__path
endfunction
call unite#custom_action('file', 'my_vsplit', g:vim_filer_tree_my_action)
""" }}}

nnoremap <Leader>f    <Nop>
nnoremap <Leader>ff   :<C-u>VimFiler<CR>
nnoremap <Leader>fnq  :<C-u>VimFiler -no-quit<CR>
nnoremap <Leader>fh   :<C-u>VimFiler ~<CR>
nnoremap <Leader>fc   :<C-u>VimFilerCurrentDir<CR>
nnoremap <Leader>fb   :<C-u>VimFilerBufferDir<CR>
nnoremap <Leader>fB   :<C-u>VimFilerBufferDir<CR>
nnoremap <silent><expr><Leader>fg ":\<C-u>VimFiler " . <SID>git_root_dir() . '\<CR>'
nnoremap <silent><expr><Leader>fe ":\<C-u>VimFilerExplorer " . <SID>git_root_dir() . '\<CR>'
nnoremap <silent>_ :<C-u>VimFilerTree<CR>
"" }}}
""" }}}

"" vim-quickrun & vim-watchdogs {{{
" 書き込み後にシンタックスチェックを行う
" let g:watchdogs_check_BufWritePost_enable = 1

" <Leader>r を使わない
let g:quickrun_no_default_key_mappings = 1
"" quickrun_configの初期化
if !has("g:quickrun_config")
  let g:quickrun_config = {}
endif
let g:quickrun_config = {
  \ 'perl' : { 'command' : 'perl', 'cmdopt' : "-M'Project::Libs lib_dirs => [qw(. local/lib/perl5 t/lib)]'" },
  \ 'go'  : { 'command' : "go",  'exec' : '%c run %s' },
  \
  \ 'syntax/perl' : {
  \   'runner' : 'vimproc',
  \   'command' : expand('~/dotfiles/bin/efm_perl.pl'),
  \   'cmdopt' : "-M'Project::Libs lib_dirs => [qw(. local/lib/perl5 t/lib)]'",
  \   'exec' : '%c %o %s:p',
  \   'quickfix/errorformat' : '%f:%l:%m',
  \ },
  \ 'syntax/ruby' : {
  \   'runner' : 'vimproc',
  \   'command' : 'ruby',
  \   'exec' : '%c -c %s:p %o',
  \ },
  \ 'watchdogs_checker/perl-projectlibs' : {
  \   'command' : 'perl',
  \   'cmdopt'  : '-MProject::Libs lib_dirs => [qw(local/lib/perl5)]',
  \ },
  \ 'perl/watchdogs_checker' : {
  \   'type' : 'watchdogs_checker/perl-projectlibs',
  \ },
\ }
" systemの代わりにvimproc#systemを使う http://vim-users.jp/2010/08/hack168/
let g:quickrun_config['*'] = {'runmode': "async:remote:vimproc", 'split': 'below'}
" QuickRun 結果の開き方
let g:quickrun_config._ = { 'outputter' : 'unite_quickfix', 'split' : 'rightbelow 10sp', 'hook/hier_update/enable' : 1 }
" outputter
let g:quickrun_unite_quickfix_outputter_unite_context = { 'no_empty' : 1 }

" autocmd MyAutocmd BufWritePost *.pl,*.pm,*.t         QuickRun -outputter quickfix -type syntax/perl
" autocmd MyAutocmd BufWritePost *.rb                  QuickRun -outputter quickfix -type syntax/ruby

nnoremap <Leader>q  <Nop>
nnoremap <silent><Leader>qr :<C-u>QuickRun<CR>
nnoremap <silent><Leader>qf :<C-u>QuickRun >quickfix -runner vimproc<CR>
vnoremap <silent><Leader>qr :QuickRun<CR>
vnoremap <silent><Leader>qf :QuickRun >quickfix -runner vimproc<CR>
nnoremap <silent><Leader>qR :<C-u>QuickRun<Space>

" call watchdogs#setup(g:quickrun_config)
"" }}}

"" vim-hier {{{
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>:HierClear<CR>
"" }}}

"" unite-ruby-require {{{
let g:unite_source_ruby_require_ruby_command = '/usr/local/opt/rbenv/shims/ruby'
"" }}}

"" perl-local-lib-path {{{
augroup PerlLocalLibPathGroup
  autocmd!
  " g:perl_local_lib_path = ["t/lib"]
  autocmd FileType perl PerlLocalLibPath
augroup END
" }}}

"" vim-rooter {{{
let g:rooter_manual_only = 1
" nnoremap <silent> <unique> <Leader>cd <Plug>RooterChangeToRootDirectory
" let g:rooter_patterns = ['cpanfile', 'Rakefile', 'Makefile', '.git/']
"" }}}

"" mhinz/vim-signify {{{
let g:signify_vcs_list = ['git', 'svn']
let g:signify_update_on_bufenter = 0
let g:signify_update_on_focusgained = 0
let g:signify_cursorhold_normal = 0
let g:signify_cursorhold_insert = 0
"" }}}

"" clever-f.vim "{{{
let g:clever_f_smart_case = 1
let g:clever_f_across_no_line = 1
" let g:clever_f_chars_match_any_signs = ';'
let g:clever_f_use_migemo = 1
" map : <Plug>(clever-f-repeat-forward)
"" }}}

"" vim-fugitive {{{
nnoremap <Leader>gs :<C-u>Gstatus<CR>
nnoremap <Leader>gC :<C-u>Gcommit -v<CR>
function! s:fugitive_commit() abort
    ZoomWin
    Gcommit -v
    silent only
    if getline('.') == ''
        startinsert
    endif
endfunction
nnoremap <Leader>gc :<C-u>call <SID>fugitive_commit()<CR>
"" }}}

"" vim-go {{{
augroup GolangCmd
  autocmd!
  autocmd FileType go nnoremap <Leader>g :GoFmt<CR>
  autocmd FileType go nnoremap <Leader>p :GoImports<CR>
  autocmd FileType go nmap <Leader>s <Plug>(go-implements)
  autocmd FileType go nmap <Leader>i <Plug>(go-info)
  autocmd FileType go nmap <Leader>gd <Plug>(go-doc)
  autocmd FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
  autocmd FileType go nmap <Leader>gb <Plug>(go-doc-browser)
  autocmd FileType go nmap <leader>r <Plug>(go-run)
  autocmd FileType go nmap <leader>b <Plug>(go-build)
  autocmd FileType go nmap <leader>t <Plug>(go-test)
  autocmd FileType go nmap <leader>c <Plug>(go-coverage)
  autocmd FileType go nmap <leader>cc <Plug>(go-coverage-clear)
  autocmd FileType go nmap <leader>ct <Plug>(go-coverage-toggle)
  autocmd FileType go nmap <leader>l <Plug>(go-lint)
  autocmd FileType go nmap <leader>v <Plug>(go-vet)
  autocmd FileType go nmap <Leader>ds <Plug>(go-def-split)
  autocmd FileType go nmap <Leader>dv <Plug>(go-def-vertical)
  autocmd FileType go nmap <Leader>dt <Plug>(go-def-tab)
  autocmd FileType go nmap <Leader>e <Plug>(go-rename)
augroup END
" let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_snippet_engine = "neosnippet"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
"" }}}

"" rust.vim {{{
let g:rustfmt_autosave = 1
let g:rustfmt_command = $HOME . '/.cargo/bin/rustfmt'

set hidden
let g:racer_cmd = $HOME . '/.cargo/bin/racer'

augroup RustCmd
  autocmd!
  autocmd FileType rust nmap gd <Plug>(rust-def)
  autocmd FileType rust nmap gs <Plug>(rust-def-split)
  autocmd FileType rust nmap gx <Plug>(rust-def-vertical)
  autocmd FileType rust nmap <Leader>gd <Plug>(rust-doc)

  autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
  autocmd BufWrite *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&"
augroup END
"" }}}

"" tagbar {{{
nmap <Leader>G :TagbarToggle<CR>
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }
"" }}}

"" memolist.vim {{{
nnoremap <Leader>mn :<C-u>MemoNew<CR>
nnoremap <silent><Leader>ml :<C-u>call <SID>memolist()<CR>
nnoremap <Leader>mg :<C-u>execute 'Unite' 'grep:'.g:memolist_path '-auto-preview'<CR>

if isdirectory(expand('~/Dropbox/memo'))
    let g:memolist_path = expand('~/Dropbox/memo')
else
    if isdirectory(expand('~/.vim/memo'))
        call mkdir(expand('~/.vim/memo'), 'p')
    endif
    let g:memolist_path = expand('~/.vim/memo')
endif

let g:memolist_memo_suffix = 'md'
let g:memolist_unite = 1
let g:memolist_unite_option = '-auto-preview -no-start-insert'

function! s:memolist()
    " delete swap files because they make unite auto preview hung up
    for swap in glob(g:memolist_path.'/.*.sw?', 1, 1)
        if swap !~# '^\.\+$' && filereadable(swap)
            call delete(swap)
        endif
    endfor

    MemoList
endfunction

let g:memolist_path = "~/Dropbox/memo"
let g:memolist_unite        = 1
let g:memolist_unite_source = "file_rec"
let g:memolist_unite_option = "-start-insert"
nnoremap <Leader>mn  :MemoNew<CR>
nnoremap <Leader>ml  :MemoList<CR>
nnoremap <Leader>mg  :MemoGrep<CR>
"" }}}

"" tagbar {{{
nnoremap <silent>+ :TagbarToggle<CR>
"" }}}

"" vim-markdown {{{
let g:vim_markdown_folding_disabled=1
"" }}}

"" vim-auto-save {{{
" let g:auto_save = 1
" let g:auto_save_in_insert_mode = 0
" let g:auto_save_no_updatetime = 0
" let g:auto_save_silent = 1
"" }}}

" committia.vim {{{
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info) abort
    " Additional settings
    setlocal spell

    " If no commit message, start with insert mode
    if getline(1) ==# ''
        startinsert
    end

    imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
    imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
endfunction
" }}}

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" vim: set ft=vim fdm=marker ff=unix fileencoding=utf-8:
