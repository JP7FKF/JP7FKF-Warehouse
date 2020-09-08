# settings

## mac
```
% brew list
autoconf    htop      libmpc      openblas    readline
bat     icu4c     libomp      openexr     rlwrap
cairo     ilmbase     libpng      openjpeg    ruby-build
fontconfig    imagemagick   libssh2     openssl     sqlite
freetype    iperf     libtiff     pango     sshuttle
fribidi     isl     libtool     pcre      telnet
gcc     jerm      libunistring    pcre2     the_silver_searcher
gd      jpeg      little-cms2   peco      tmux
gdbm      jq      lua     pixman      tree
gettext     libcerf     maxima      pkg-config    watch
git     libde265    mpfr      postgresql    webp
glib      libevent    mtr     pyenv     wget
gmp     libffi      ncurses     python      x265
gnuplot     libgit2     nmap      qt      xz
graphite2   libheif     node      r     zsh
harfbuzz    libidn2     oniguruma   rbenv
```
## iterm
- `/Users/yudaihashimoto/.iterm_log` にsession logをとる．

## sublime text
- 基本的にgitでsettingを管理することにする. dotfilesレポジトリを使う．
- `dotfiles/sublimetext/`配下がいわゆる`~/Library/ApplicationSupport/Sublime Text 3/`配下相当になる．
- このうち，package control公式の見解の通り，`Packages/User/`ディレクトリ配下の特定のファイル以外についてgitで管理する．
```
Using Git
Many developers are familiar with Git, and it is a logical choice for keeping files in sync across machines if you don't mind a little manual work. There are a few things to keep in consideration when using Git:

If you use a service like GitHub and do not use a private repository, you may accidentally share license keys for any commercial packages you have purchased.
Certain files and folders in the Packages/User/ folder change regularly, so you may want to add them to a .gitignore file. There is really no harm in syncing these, however some of them change on an hourly basis, which may result in having to run more Git commands. Examples include:

Package Control.last-run
Package Control.ca-list
Package Control.ca-bundle
Package Control.system-ca-bundle
Package Control.cache/
Package Control.ca-certs/
```
- `setup.sh`を用意しているので，syncしたいディレクトリ配下(ex. dotfiles/sublimetext/User/)で`sh setup.sh`すると`~/Library/ApplicationSupport/Sublime Text 3/Packages/User/`配下の同期すべきファイル群が，`dotfiles/Packages/User/`配下の実態ファイルへのシンボリックリンクで置き換わる．既存のファイルはシンボリックリンクで上書きされてしまうため注意する必要がある．必要ならバックアップ等を取得する．
  - backup ex.: `cp -r ~/Library/ApplicationSupport/Sublime Text 3 ~/Library/ApplicationSupport/Sublime Text 3.bak`
- ライセンス販売されたpackage等を入れる場合にはキーの流出等がないようcommit/push 時には留意する．かならず`git add -N hoge/git diff`する．
- refs
  - [Syncing - Package Control](https://packagecontrol.io/docs/syncing)
  - [Sublime Text3導入メモ - shoya\.io](https://shoya.io/ja/posts/hello-sublime/)
  - [Sublime Text2,3のDropbox, Gitを使った同期の方法 - Qiita](https://qiita.com/matsu_chara/items/b58564bba37e81637057)
