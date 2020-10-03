# Unix Basic Commands

## df -h
  - 容量みれる

## du -sh *
  - 今の階層下のフォルダやファイルの容量をみる．

## traceroute
- `traceroute -a x.x.x.x` でAS名も一緒に引ける．(-A でas_serverを指定できる)
- 尻尾になんかついてきたら
```
- !H: [Type=3/Code=1] Host Unreachable
- !X: [Type=3/Code=13] Communication Administratively Prohibited
- !N: [Type=3/Code=0] Net Unreachable
- !P: [Type=3/Code=2] Protocol Unreachable
- !F: [Type=3/Code=4] Fragmentation Needed and DF set
- !S: [Type=3/Code=5] Source route failed
- !V: [Type=3/Code=14] Host Precedence
- !<icmp_code_num>
```
- `-I`: オプションで強制的にICMPで投げる．
- TODO: traceroute のフィールドがわからない．なんでICMP強制したら`*`になったんだ．パケットを見させてくれたのむ

## tmux とかnohupするの忘れて長時間かかるコマンドをやってしまったとき
```
$ rpmbuild -ba hoge.spec // やっちまった
$ # Ctrl+Zで中断
$ bg 1
$ jobs 1
$ disown %1
```
- nohupとdisownの違いは
  - nohup:コマンドをハングアップシグナル無視で実行させる．
  - disown:nohupをつけ忘れた時，途中からバックグラウンドでの実行へ切り替える

## PIDファイルが残っている/subsys locked
```
$ service <service_name> status
<service_name> が停止していますが PID ファイルが残っています
$ rm /var/run/<service_name>.pid
rm: cannot remove `/var/run/<service_name>.pid': Permission denied
$ sudo rm /var/run/<service_name>.pid
$ service <service_name> status
<service_name> は停止していますがサブシステムがロックされています
$ sudo rm /var/lock/subsys/<service_name>
$ service <service_name> status
<service_name> は停止しています
$ sudo service <service_name> restart
```

## サブネット全部にpingしたい
  - `for a in `seq 1 254`; do ping -c 1 -w 1 10.0.255.$a > /dev/null && arp -a 10.0.255.$a | grep ether; done`
    - 便利なワンライナー．wrap/aliasしてもいいかも．

## ブロードキャストping
- `netdiscover -r <netaddr/mask>`
- `for a in `seq 1 254`; do ping -c 1 -w 1 192.168.1.$a > /dev/null && arp -a 192.168.1.$a | grep ether; done`
- `nmap -sP <netaddr/mask>`

## curlでproxy経由する
  - `curl -x <proxy>:<port> -L http://example.com`

## iptables
```
$ vi /etc/sysconfig/iptables #ここにinitのtablesが書かれている
$ iptables-save > filename #export
$ iptables-restore < filename #import
$ service iptables save # 現在のiptablesの情報をinitにする(たぶん/etc/sysconfig/iptablesに書きに行く？)
  iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
```

## ping のTTL
- TTLのデフォルト値（だいたい）
  - Linux：64
  - Windows：128
  - Solaris：255

## httping
- httpでpingする感じ．
- `httping <address>` で基本的には動く．
  - headメソッドでリクエストを投げる．
- `-G` オプションでGETを投げる．
- 他にもプロキシ指定(-x proxyserver:port)したり，タイムアウト(-t)，インターバル(-i)，http status code(-s)，URL指定(-g)などのオプションがある．

## grep
- `grep -r <search_str> <search_dir_1> <search_dir_2>...`

## find
- `find <search_dir> -name <file_name>`

```
# you can filter out messages to stderr. I prefer to redirect them to stdout like this.
$ find / -name art  2>&1 | grep -v "Permission denied"

# Explanation:
# In short, all regular output goes to standard output (stdout). All error messages to standard error (stderr).
# grep usually finds/prints the specified string, the -v inverts this, so it finds/prints every string that doesn't contain "Permission denied".
# All of your output from the find command, including error messages usually sent to stderr (file descriptor 2) go now to stdout(file descriptor 1) and then get filtered by the grep command.
# This assumes you are using the bash/sh shell.

# Under tcsh/csh you would use
$ find / -name art |& grep ....
 ```

## 容量の大きいディレクトリtop10
- なんのせいでdiskが逼迫しているかわからないときよくある．
- `du -m / | sort -nr | head -10`

## シンボリックリンク
- `ln -s <origin> <link_name(optional)>`
- `unlink <link_name>`

## less
  - `-r` オプションをつけるとカラーとかが制御文字で表示されなくていい．

## ユーザ系
### 新しいユーザ
```
useradd <user>
  # -m: ホームディレクトリも一緒に作る
  # -s <path_to_shell> shell指定
  # -p: ハッシュ化したパスワード指定
# sudo できるように
usermod -G wheel <user> #wheelとかsudoとか必要があれば
vi /etc/sudors
  #100行目前後
  # %wheel        ALL=(ALL)       ALL
passwd <user> でパス変更しておこう
```
- `usermod -aG <GROUPS> <USER> #GROUPSはカンマ区切りで複数指定可`
- `gpasswd -a <USER> <GROUP>`
- `adduser <USER> <GROUP>`

### デフォルトshellを変える
- `chsh -s <path_to_shell> <user_name>`
- もしくは `/etc/passwd`の該当ユーザの末尾に`<path_to_shell>`を追加
- `cat /etc/shells`で使えるshell一覧

### sudors
- `visudo` する
```
 $ 誰が どのホストで = (誰として) 何を
# rootユーザはどこでも，誰としてでも何でもできる
 $ root ALL=(ALL:ALL) ALL
# wheelグループのユーザはどこでも，誰としてでもパスワード無しで何でもできる
# %つけるとgroup指定．誰としての部分は(user:group)
 $ %wheel ALL=(ALL:ALL) NOPASSWD: ALL
# bobはaliceとして閲覧コマンドを実行できる
 $ bob ALL=(alice) /bin/ls, /bin/cat
```

### groups
- ユーザのグループ確認
  - `groups <user_name>`
  - もちろん `/etc/group` でも見れる
- ユーザをグループに追加
  - `usermod -aG <group_name> _<user_name>`
   - groupsは複数指定できる(comma separation)
  - `gpasswd -a <user_name> <group_name>`
  - どっちでもいっしょ．`usermod`使うときは `-a`を忘れないようにしないとセカンドグループが上書きになるので注意．`-a`はaddの意．
- グループに所属しているuserを確認
  - `getent group <group_name>`
- グループに入る(login)
  - `newgrp <group name>`
    - グループにログインした状態でファイル等を作成すると，そのファイルのプライマリグループがログインしたグループとなる．
- グループのパスワードを設定
  - `gpasswd <group_name>`

## git
### 脳死commit
- いいからかけ．脳死コミットができあがる．
  - ``alias gitcmtnow='git commit -m "`date "+%Y-%m-%d %H:%M:%S"`"'``
  - 脳死してcommitしたいときに便利．zshrcやらbashrcに書いておこう．脳死しよう．

### gitignoreをglobalにかく
1. `~/.gitconig` にexcludersfileを書く．
2. 上記で書いたexcludersfileにgitignoreを書く．

- `$ git config --global core.excludesfile ~/.gitignore_global`

```
## .gitconfig
[core]
    excludesfile = /Users/<username>/.gitignore_global
```

- .gitignore_global に .DS_Store を追加する
```
## .gitignore_global
.DS_Store
```

## diff
- フォルダごとdiffとりたい
  - `diff -r <dir_1> <dir_2>`
  - `-u`: unified形式 (大文字でn行指定)
  - `-c`: context形式 (大文字でn行指定)
  - `-y`: 2カラム形式
    - `sdiff` っぽい．
    - `-W`で合計の横幅を指定できる．

## netstat
- `netstat -rn`
- `netstat -tuna`

- Options
  - `-n, --numeric`: show with numeric address. no dns lookup (more speedy!)
  - `-t, --tcp`: tcp
  - `-u, --udp`: udp
  - `-a, --all`: all information
  - `-i, --interface <interface_name>`: designate interface
  - `-s, --statistics`: show statictics
  - `-c, --continuous`: show with continuouts refreshments.
  - `-o, --timers`: show network timers
  - `-e, --extend`: show extended information
  - `-l, --listening`: show listening sockets

## wc
- word count
- Options
  - `-l`: counts num of lines
  - `-c`: counts bytes
  - `-m`: counts num of characters
  - `-w`: counts num of words

## watch
### Options
  - `-d, --differences[=permanent]`: 変更があった場合にハイライトする. `=permanent` つけておくと当たり前だがずっとハイライトが残る．
  - `-n, --interval <seconds>`
  - `-t, --no-title`
  - `-b, --beep`: Beep if command has a non-zero exit.
  - `-e, --errexit`: Freeze updates on command error, and exit after a key press.
  - `-g, --chgexit`: Exit when the output of command changes.
  - `-c, --color`: Interpret ANSI color and style sequences.
  - `-x, --exec`: Pass command to exec(2) instead of sh -c which reduces the  need to use extra quoting to get the desired effect.

### EXIT STATUS
```
0      Success.
1      Various failures.
2      Forking the process to watch failed.
3      Replacing  child  process  stdout  with  write  side pipe
       failed.
4      Command execution failed.
5      Closing child process write pipe failed.
7      IPC pipe creation failed.
8      Getting  child  process  return  value  with   waitpid(2)
       failed, or command exited up on error.
other  The  watch  will  propagate  command exit status as child
       exit status.
```

## FTP
- `open <ip/name>`
- `cd`, `ls`, `mkdir`, etc...
- `put`, `get`
- `mput`, `mget`
  - ex. `mget *.jpg`
- `asc`: asciimode, `bin`: binarymode
- `close`
```
[jp7fkf@lab1]$ ftp
ftp> open ftp.riken.jp
Connected to ftp.riken.jp (134.160.38.1).
220 ::ffff:134.160.38.1 FTP server ready
Name (ftp.riken.jp:jp7fkf): anonymous
331 Anonymous login ok, send your complete email address as your password
Password:
230-******************************************************
 ftp.riken.jp is an unsupported ftp/http/https/rsync
 service of RIKEN Nishina Center for research support.
 Use entirely at your own risk - no warranty
 is expressed or implied.
 Complaints and questions should be sent to
 ftp-admin a.t. ftp.riken.jp
 ******************************************************
230 Anonymous access granted, restrictions apply
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (134,160,38,1,131,149).
150 Opening ASCII mode data connection for file list
drwxr-xr-x   4 root     root         4096 Apr  8  2013 cernlib
lrwxrwxrwx   1 root     root           11 Aug 28  2014 CTAN -> tex-archive
drwxr-xr-x   8 archive  archive      4096 Jul 14 12:15 FreeBSD
drwxr-xr-x   9 root     root         4096 Nov 19  2014 GNU
-rw-r--r--   1 root     root          700 May 16 03:37 HEADER.html
drwxr-xr-x  12 root     root         4096 Feb 21  2015 iris
drwxr-xr-x   3 root     root           17 Jul  7  2008 lang
drwxr-xr-x   3 root     root           16 Dec 27  2010 Lecture
drwxr-xr-x  35 root     root         4096 Jun  3 05:14 Linux
drwx------   6 root     root           69 Aug  7  2014 misc
drwxr-xr-x  15 root     root         4096 Jun 14  2018 net
drwxr-xr-x  20 archive  archive      4096 Jul 17 00:27 NetBSD
drwxr-xr-x   4 root     root           33 Sep  9  2015 office
drwxr-xr-x  15 archive  archive      4096 Jul 17 03:15 OpenBSD
drwxr-xr-x   5 root     root           53 Jul  5  2013 pc
drwxr-xr-x   2 root     root         4096 Oct 31  2018 pub
drwxrwxr-x  12 archive  archive      4096 Jul 16 21:15 sagemath
drwxr-xr-x  18 archive  archive      4096 Jul 16 23:14 tex-archive
d---------   2 root     root            6 Jan 31  2018 uploads
-rw-r--r--   1 root     root          224 Jan 31  2018 welcome.msg
drwxrwxr-x  10 archive  archive      4096 Jul  2 21:15 X11
226 Transfer complete
ftp> cd FreeBSD
250-ISO images of FreeBSD releases may be found in the releases/ISO-IMAGES
 directory.  For independent files and tarballs, see individual
 releases/${machine}/${machine_arch} directories.  For example,
 releases/amd64/amd64 and releases/powerpc/powerpc64.
250 CWD command successful
ftp> ls
227 Entering Passive Mode (134,160,38,1,136,63).
150 Opening ASCII mode data connection for file list
drwxr-xr-x   9 archive  archive      4096 Jul 14 12:15 development
-rw-r--r--   1 archive  archive      2269 Jul 13 10:00 dir.sizes
drwxr-xr-x  28 archive  archive      4096 Nov 12  2017 doc
drwxr-xr-x   5 archive  archive        56 Nov 12  2017 ports
-rw-r--r--   1 archive  archive      4259 May  7  2015 README.TXT
drwxr-xr-x  10 archive  archive      4096 Jul 14 12:17 releases
drwxr-xr-x  10 archive  archive      4096 Nov  9  2018 snapshots
-rw-r--r--   1 archive  archive        35 Jul 14 09:15 TIMESTAMP
226 Transfer complete
ftp> cd deve
550 deve: No such file or directory
ftp> cd development
250 CWD command successful
ftp> ls
227 Entering Passive Mode (134,160,38,1,158,89).
150 Opening ASCII mode data connection for file list
drwxr-xr-x   2 archive  archive        47 Nov 12  2017 CSRG
drwxr-xr-x   2 archive  archive        27 Jan  5  2018 CTM
drwxr-xr-x   3 archive  archive      4096 Nov 12  2017 CVS-archive
drwxr-xr-x   4 archive  archive        62 Nov 12  2017 CVSup
drwxr-xr-x   2 archive  archive        90 Nov 12  2017 gnats-archive
drwxr-xr-x   2 archive  archive      4096 Oct 20  2018 subversion
drwxr-xr-x   2 archive  archive      4096 Jul 14 12:15 tarballs
-rw-r--r--   1 archive  archive        35 Jul 14 09:15 TIMESTAMP
226 Transfer complete
ftp> cd tarballs
250 CWD command successful
ftp>
ftp> ls
227 Entering Passive Mode (134,160,38,1,150,80).
150 Opening ASCII mode data connection for file list
-rw-r--r--   1 archive  archive  97028667 Jul 14 01:01 doc_current.tar.gz
-rw-r--r--   1 archive  archive  58952447 Jul 14 01:21 ports_current.tar.gz
-rw-r--r--   1 archive  archive  253262428 Jul 14 01:31 src_current.tar.gz
-rw-r--r--   1 archive  archive  202838063 Jul 13 01:36 src_stable_10.tar.gz
-rw-r--r--   1 archive  archive  246360289 Jul 14 01:39 src_stable_11.tar.gz
-rw-r--r--   1 archive  archive  28389329 Nov 10  2016 src_stable_2.0.5.tar.gz
-rw-r--r--   1 archive  archive  30007804 Nov 10  2016 src_stable_2.1.tar.gz
-rw-r--r--   1 archive  archive  38802445 Nov 10  2016 src_stable_2.2.tar.gz
-rw-r--r--   1 archive  archive  53130095 Nov 10  2016 src_stable_3.tar.gz
-rw-r--r--   1 archive  archive  83185063 Nov 10  2016 src_stable_4.tar.gz
-rw-r--r--   1 archive  archive  97265038 Nov 10  2016 src_stable_5.tar.gz
-rw-r--r--   1 archive  archive  100357754 Nov 10  2016 src_stable_6.tar.gz
-rw-r--r--   1 archive  archive  115919712 Aug 27  2018 src_stable_7.tar.gz
-rw-r--r--   1 archive  archive  124838527 Dec 27  2018 src_stable_8.tar.gz
-rw-r--r--   1 archive  archive  169774261 Jun 12 01:05 src_stable_9.tar.gz
226 Transfer complete
ftp> cd
(remote-directory)
usage: cd remote-directory
ftp> cd ..
250 CWD command successful
ftp> ls
227 Entering Passive Mode (134,160,38,1,167,42).
150 Opening ASCII mode data connection for file list
drwxr-xr-x   2 archive  archive        47 Nov 12  2017 CSRG
drwxr-xr-x   2 archive  archive        27 Jan  5  2018 CTM
drwxr-xr-x   3 archive  archive      4096 Nov 12  2017 CVS-archive
drwxr-xr-x   4 archive  archive        62 Nov 12  2017 CVSup
drwxr-xr-x   2 archive  archive        90 Nov 12  2017 gnats-archive
drwxr-xr-x   2 archive  archive      4096 Oct 20  2018 subversion
drwxr-xr-x   2 archive  archive      4096 Jul 14 12:15 tarballs
-rw-r--r--   1 archive  archive        35 Jul 14 09:15 TIMESTAMP
226 Transfer complete
ftp> cd ..
250-ISO images of FreeBSD releases may be found in the releases/ISO-IMAGES
 directory.  For independent files and tarballs, see individual
 releases/${machine}/${machine_arch} directories.  For example,
 releases/amd64/amd64 and releases/powerpc/powerpc64.
250 CWD command successful
ftp>
ftp> ls
227 Entering Passive Mode (134,160,38,1,163,208).
150 Opening ASCII mode data connection for file list
drwxr-xr-x   9 archive  archive      4096 Jul 14 12:15 development
-rw-r--r--   1 archive  archive      2269 Jul 13 10:00 dir.sizes
drwxr-xr-x  28 archive  archive      4096 Nov 12  2017 doc
drwxr-xr-x   5 archive  archive        56 Nov 12  2017 ports
-rw-r--r--   1 archive  archive      4259 May  7  2015 README.TXT
drwxr-xr-x  10 archive  archive      4096 Jul 14 12:17 releases
drwxr-xr-x  10 archive  archive      4096 Nov  9  2018 snapshots
-rw-r--r--   1 archive  archive        35 Jul 14 09:15 TIMESTAMP
226 Transfer complete
ftp> get README.TXT
local: README.TXT remote: README.TXT
227 Entering Passive Mode (134,160,38,1,139,90).
150 Opening BINARY mode data connection for README.TXT (4259 bytes)
226 Transfer complete
4259 bytes received in 0.0137 secs (311.17 Kbytes/sec)
ftp> asc
200 Type set to A
ftp> bin
200 Type set to I
ftp> close
221 Goodbye.
ftp> quit
[jp7fkf@lab1]$ ls
 README.TXT
```

## lsof
- プロセスが開いているファイルらを表示する．

### options
- `-P`: ポート番号をサービス名に変換しない
- `-c`: プロセス名を指定
- `-i`: ネットワークソケットファイルを指定
- `-n`: IPアドレスを表示（名前解決しない）
- `-p`: プロセスIDを指定
- `-u`: ユーザー名を指定

### examples
- `lsof -i:80`: 80番ポートのappsを表示する．
- `lsof -i`: ネットワークソケットファイル全部見る．

## systemd
- systemdのファイルを参照したい
- `systemctl cat <service_name>` する．
```
jp7fkf@lab1:~$ systemctl cat zabbix-server.service
# /lib/systemd/system/zabbix-server.service
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/etc/zabbix/zabbix_server.conf"
EnvironmentFile=-/etc/default/zabbix-server
Type=forking
Restart=on-failure
PIDFile=/run/zabbix/zabbix_server.pid
KillMode=control-group
ExecStart=/usr/sbin/zabbix_server -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target
```

## fallocate
- ddとかの代わりにdummyファイル生成するときに便利
  - `fallocate -l <filesize(ex: 1G, 1M, 1K)> <filename>`
- 実際にファイル生成はされておらず，ディスク領域の予約のみを行うため実際にファイルに書き込むddコマンドよりも時間がかからない．

## ddコマンド
- dataset difinition
- データをブロック単位で転送したり，dummyファイルを作ったりできる．
- `dd if=/dev/cdrom of=install.iso`
  - cdromの内容を直接iso化する．
- `dd bs=1K count=100 if=/dev/zero of=dummy`
  - 1K x 100 = 100Kバイトのファイル生成できる．

## メモリキャッシュ
- 現在のメモリ使用状況を確認
  - `free -h`
    ```
    jp7fkf@lab:~$ free -h
                  total        used        free      shared  buff/cache   available
    Mem:           3.8G        265M        2.7G         40M        862M        3.4G
    Swap:            9G        197M        9.8G
    ```
    - cached: ページキャッシュ．ファイルシステムに対するキャッシュであり，ファイル単位でアクセスするときに使用されるキャッシュ．
    - buffers: バッファキャッシュが存在する．ブロックデバイスを直接アクセスするときに使用されるキャッシュになる．

  - `vmstat -a`
    - inactとactがあるが，このinactのものは削除可能．actは削除できない．
    ```
    jp7fkf@lab:~$ vmstat -a
    procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
     r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
     0  0 201868 2865132 131688 753296    0    0     2     6    0    0  2  1 97  0  0
    ```

- キャッシュの解放
  - cacheは高速化のために有益だが，事情があって削除したい場合，パフォーマンス測定を実施する場合にキャッシュの影響を消したい場合などは下記コマンドで削除できる．
  - `sync` してDirty cache を書き出す．
  - `echo 3 > sudo /proc/sys/vm/drop_caches`
    - もしくは, `sudo sysctl -w vm.drop_caches=3`

- ref: [Ubuntu メモリキャッシュクリア: プログラマの歩き方](http://zorinos.seesaa.net/article/451160288.html)
- ref: [How to Clear RAM Memory Cache, Buffer and Swap Space on Linux](https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/)

## gzipを解凍する．
- `.gz`
  - `gunzip <filename>`
  - `gzip -d <filename>`
- `tar.gz`
  - `tar xzvf <filename>`
  - 圧縮パッケージを作る場合: `tar czvf <output_filename> <input_dir_name>`
- 　gzipでは，複数のファイルを圧縮して1つのファイルにまとめることはできない．ディレクトリごと圧縮して1ファイルにまとめたい場合は，tar でパッケージした後，gzipで圧縮する．
- tarはアーカイバ．複数ファイルを1つにまとめる．
- gzipは圧縮機能．ファイルを圧縮するだけ．複数ファイルを1つにまとめることはできない．
- zipは圧縮アーカイバ．複数ファイルをまとめることができ，かつ圧縮できる．

- tar のoptions
  - `c`: create
  - `v`: verbose
  - `f`: filename
  - `x`: extract
  - `z`: `gz`
  - `j`: `bz2`
  - `J`: `xz`

## 乱数文字列生成
- `echo $(cat /dev/urandom | LC_ALL=C tr -dc '[:alnum:]' | head -c 20)`
  - `tr: Illegal byte sequence` とか言われるときのために`LC_ALL=C`をいれてある．`LC_CTYPE=C`だけでも解決できる場合があるがダメなこともあるのでおとなしく`LC_ALL=C`でいけばいいと思う．
  - また，classは下記のような種類があるので要件に応じて使い分けると良さそうだ．
  - ex.) `echo $(cat /dev/urandom | LC_ALL=C tr -dc '[:print:]' | head -c 10) # '7+2vNPF$\`
  ```
  # man tr より抜粋
  [:class:]  Represents all characters belonging to the defined character class.  Class names are:

  alnum        <alphanumeric characters>
  alpha        <alphabetic characters>
  blank        <whitespace characters>
  cntrl        <control characters>
  digit        <numeric characters>
  graph        <graphic characters>
  ideogram     <ideographic characters>
  lower        <lower-case alphabetic characters>
  phonogram    <phonographic characters>
  print        <printable characters>
  punct        <punctuation characters>
  rune         <valid characters>
  space        <space characters>
  special      <special characters>
  upper        <upper-case characters>
  xdigit       <hexadecimal characters>
  ```

## testでmd5とかshaををテストする． 0なら一致．1なら不一致．
```
## md5
md5 -q <filename> | xargs -I _ test _ = <md5>; echo $?

## sha1
shasum -a 1 <filename> | awk '{print $1}' | xargs -I _ test _ = <sha1>; echo $?

## -c で空白区切で `<hash> <filename>` となっているファイルを読んで実行した階層の下のファイルを検査する．
% touch test
% shasum -a 1 test
da39a3ee5e6b4b0d3843bfef95601890afd80709  test
% shasum -a 1 test >> test.sha1
% shasum -a 1 -c test.sha1
test: OK
```

## unixtimeからhuman readableな時刻に変換
```
$ date -r 156680063
Mon Aug 26 15:23:56 JST 2019
```

## bash prompt color
- プロンプトの色をかえるexample
```
STARTFGCOLOR="\[\e[0;31m\]"
STARTBGCOLOR="\[\e[48m\]"
ENDCOLOR="\[\e[0m\]"
export PS1="$STARTFGCOLOR$STARTBGCOLOR\u@\H:\w\$ $ENDCOLOR"
```
  - `\e[`: ASCII escaping

- colormap
```
Black       0;30     Dark Gray     1;30
Red         0;31     Light Red     1;31
Green       0;32     Light Green   1;32
Brown       0;33     Yellow        1;33
Blue        0;34     Light Blue    1;34
Purple      0;35     Light Purple  1;35
Cyan        0;36     Light Cyan    1;36
Light Gray  0;37     White         1;37
```
左側はbold flag. bold flagつけると色もやや明るくなる．

```
\u : username
\h : fqdn
\H : 今いるディレクトリ名
\w : dir rel path
\W : current dir name
\$ : prompt(normal user: $, root user: #)
\t : time(24h)
\T : time(12h)
\@ : AM/PM
\d : datetime(simple)
\D : datetime
```
- ref: [ターミナルの表示内容(プロンプト)の変更・カスタマイズ方法まとめ - Qiita](https://qiita.com/hmmrjn/items/60d2a64c9e5bf7c0fe60)

## カジュアルにncでhttp request
- `(echo "GET / HTTP/1.1";echo "Host: 10.2.0.5:80";echo "Accept */*";echo) | nc 10.0.0.1 80 -v`

## netcatでhttp server
- `while true; do; echo -e "HTTP/1.1 200 OK\n\n $(date)" | nc -l 8080; done`
  - 終了するときは`C-z`して`kill`する必要あり．
