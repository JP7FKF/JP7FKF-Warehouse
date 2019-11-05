# DNS
## DNSに関するRFC
RFC1034, RFC1035, RFC1912, RFC2181あたりをざっくりと
RFC3484にはこう書かれている．
```
 Rule 8:  Use longest matching prefix.
   If CommonPrefixLen(SA, D) > CommonPrefixLen(SB, D), then prefer SA.
   Similarly, if CommonPrefixLen(SB, D) > CommonPrefixLen(SA, D), then
   prefer SB.
```
つまるところ，複数のIPアドレスリストをDNS answerとしてクライアントに返す場合，これまでは'answerのIPアドレスリストのうち最初のIPアドレスから順に使うクライアントが"多かった"'のだが，RFC3484に準拠した実装が行われているクライアントでは，自分のIPアドレスとのロンゲストマッチをとったIPアドレスリストのうちの最初のものから順に使って行くようである．DNSラウンドロビンなどで複数のIPアドレスリストを返す場合に，DNSサーバが構成したリストの最初の1番目が利用されるわけではなくなるということになる．
これを知っておかないと意図した動作と異なるふるまいをしそうなので注意が必要そう．
- [CNAME を巡る 2/3 のジレンマ - 鷲ノ巣](https://tech.blog.aerie.jp/entry/2014/09/09/162135)

- [RFC 1912 -  Common DNS Operational and Configuration Errors](https://www.ietf.org/rfc/rfc1912.txt)

## 代表的なdns ソフトウェア
- Bind
  - 有名．脆弱性がちょっと多い印象．
- Power DNS
  - Web GUIがあり，レコード登録などの取り扱いがやりやすい．
- Unbound
  - DNSキャッシュサーバ．コンテンツサーバにはなれない．
  - DNSキャッシュサーバとしては，BINDを完全に置き換えることができる程度の機能は実装されている．
- Knot DNS
  - 権威DNS（コンテンツサーバ）専用
  - キャッシュサーバ(resolver)として使いたい場合は`Knot DNS resolver` というものもある．
    - cloudflare(1.1.1.1)で使われているらしい．

## Primary DNSはどっち？
  - `dig @<server> example.com ns`
    ```
      #...
      #;; ANSWER SECTION:
      #example.com.   87468 IN  NS  ns2.example.com.
      #example.com.   87468 IN  NS  ns1.example.com.
      #...
    ```
  - `dig @<server> ns1.example.com soa`
    ```
      # example.com.   180 IN  SOA ns1.example.com. hoge.example.com. ...
    ```
  - `dig @<server> ns2.example.com soa`
    ```
      # example.com.   180 IN  SOA ns1.example.com. hoge.example.com. ...
    ```

  - この場合，SOAがns1なので，ns1がprimary と機能していると見ることができる．
  
## ゾーン転送
  - `dig @<server> <domain> axfr`

## bindのlogging
  - https://oxynotes.com/?p=7469

## bind9.11.1で`geoip-use-ecs` optionが使えない (2019-02-25 YudaiHashimoto)
  - docには載っているのにな...．
  - `Feb 23 06:09:32 76efffadff20 bash[27022]: /etc/named.conf:32: unknown option 'geoip-use-ecs'`

## bind9 build battle
  - bind9.13らへんをいれたかった．
    - http://linux-sxs.org/internet_serving/bind9.html
    ```
    $ wget https://www.openssl.org/source/openssl-1.0.2q.tar.gz
    $ tar xvzf openssl-1.0.2q.tar.gz
    $ cd openssl-1.0.2q/
    $ perl util/perlpath.pl `which perl` //はいらなかった
    $ ./config --prefix=/usr --openssldir=/usr/ssl shared
    $ make
    $ su
    $ rpm -q -a | grep openssl | while read line; do rpm -e --nodeps $line; done
    $ make install
    $ ldconfig -v

    $ wget ftp://ftp.isc.org/isc/bind9/9.13.2/bind-9.13.2.tar.gz
    $ tar xvzf bind-9.13.2.tar.gz
    $ cd bind-9.13.2/
    $ yum provides *sys/capability.h
    $ yum install libcap-devel
    $ ./configure --prefix=/usr --sysconfdir=/etc --enable-threads --localstatedir=/var/state --with-libtool --with-openssl=/usr/
    $ make
    $ su
    $ rpm -q -a | grep '^bind' | while read line; do rpm -e --nodeps $line; done
    $ ldconfig -v
    $ groupadd named
    $ vigr
    $ chown root:daemon /var/run
    $ chmod 775 /var/run
    $ mkdir -p /var/named/pz
    $ chown -R named:named /var/named
    $ chmod -R 755 /var/named
    ```

  - 9.11 on docker
    - https://qiita.com/shadowhat/items/a597c83400e59024a350
    ```
      [jp7fkf@jp7fkf_0 ~]$ sudo docker pull centos:latest
      latest: Pulling from library/centos
      a02a4930cb5d: Pull complete
      Digest: sha256:184e5f35598e333bfa7de10d8fb1cebb5ee4df5bc0f970bf2b1e7c7345136426
      Status: Downloaded newer image for centos:latest
      [jp7fkf@jp7fkf_0 ~]$
      [jp7fkf@jp7fkf_0 ~]$ docker images
      Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/images/json: dial unix /var/run/docker.sock: connect: permission denied
      [jp7fkf@jp7fkf_0 ~]$ sudo docker images
      REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
      centos              latest              1e1148e4cc2c        2 months ago        202MB
      [jp7fkf@jp7fkf_0 ~]$ sudo docker run -it -d --privileged --name bind911 centos:latest /sbin/init
      76efffadff20224247573edb5d5a03834b3be5b9868683542a4fab766c8d55ee
      [jp7fkf@jp7fkf_0 ~]$
      [jp7fkf@jp7fkf_0 ~]$ sudo docker exec -it 76ef /bin/bash
    ```
    ```
      $ yum update
      $ yum install openssl openssl-devel
      $ cd /usr/local/src
      $ yum install wget
      $ wget --trust-server-name https://www.isc.org/downloads/file/bind-9-11-1/?version=tar-gz
      $ mv index.html?version=tar-gz bind-9-11-1-p1.tar.gz
      $ tar xvzf bind-9-11-1-p1.tar.gz
      $ cd bind-9.11.1/
      $ yum install gcc perl
      $ ./configure --with-libtool --with-openssl --prefix=<install先>
      $ make
      $ make install
    ```
    - systemctl であがらない
      ```
        $ journalctl -xe
        Feb 23 05:41:50 76efffadff20 named[26825]: isc_stdio_open 'data/named.run' failed: file not found
      ```
      - 脳死で `yum install bind-chroot`


## unboundをdockerにたてる
  - docker でcentosをたてておく．
  ```
    yum update
    yum install unbound
    curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
    vi /etc/unbound/unbound.conf
    unbound-checkconf
    systemctl start unbound
    yum install bind-utils
    dig @localhost www.google.com
  ```
  - ハマりどころ
    - dnssecがdefaultでonになっているっぽい．
    - `/etc/unbound/unboud.conf`のmodule-configからvalidatorとipsec系のmoduleを消す．
      - fastlyのunbound.confなんてmodule-config自体commented out されてたな :thinking_face:
      - `module-config: "iterator"` となっていればok
    - https://unbound.jp/unbound/howto_turnoff_dnssec/

## 基本config
  - このあたり書いておけばとりあえずresolverとしては動きそう．細かいことはgoogleって人がよく知っているので聞いてみるといい．
    - interface
    - do-ipv4
    - do-ipv6
    - do-udp
    - do-tcp
    - access-control
    - root-hints
    - forward-zose
      - name
      - forward-addr


### ログを取る
```
  server: 
    logfile: "/var/unbound/var/log/unbound.log"
    use-syslog: no
```

## localにかいとくとき．
```
  local-zone: "***.hoge.local." static
  local-data: "IN NS ns1.hoge.local."
  local-data: "IN NS ns2.hoge.local."
  local-data: "ns1.hoge.local. IN A 10.0.0.1"
  local-data: "ns2.hoge.local. IN A 10.0.0.2"
```

## vimにペーストするときにインデントされるのを防止
  - ペーストモード
    - `:set paste` を打ってから入力
  - alコマンド
    - `:al` して貼り付け


## unbound

## unbound install battle on ubuntu18.04
- 2019/07現在下記のパッケージがある．(1.6.7)
```
jp7fkf@lab1:~$ sudo apt list -a | grep unbound

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

libghc-unbounded-delays-dev/bionic 0.1.1.0-1 amd64
libghc-unbounded-delays-doc/bionic 0.1.1.0-1 all
libghc-unbounded-delays-prof/bionic 0.1.1.0-1 amd64
libunbound-dev/bionic-updates 1.6.7-1ubuntu2.2 amd64
libunbound-dev/bionic-security 1.6.7-1ubuntu2.1 amd64
libunbound-dev/bionic 1.6.7-1ubuntu2 amd64
libunbound2/bionic-updates 1.6.7-1ubuntu2.2 amd64
libunbound2/bionic-security 1.6.7-1ubuntu2.1 amd64
libunbound2/bionic 1.6.7-1ubuntu2 amd64
python-unbound/bionic-updates 1.6.7-1ubuntu2.2 amd64
python-unbound/bionic-security 1.6.7-1ubuntu2.1 amd64
python-unbound/bionic 1.6.7-1ubuntu2 amd64
python3-unbound/bionic-updates 1.6.7-1ubuntu2.2 amd64
python3-unbound/bionic-security 1.6.7-1ubuntu2.1 amd64
python3-unbound/bionic 1.6.7-1ubuntu2 amd64
unbound/bionic-updates 1.6.7-1ubuntu2.2 amd64
unbound/bionic-security 1.6.7-1ubuntu2.1 amd64
unbound/bionic 1.6.7-1ubuntu2 amd64
unbound-anchor/bionic-updates 1.6.7-1ubuntu2.2 amd64
unbound-anchor/bionic-security 1.6.7-1ubuntu2.1 amd64
unbound-anchor/bionic 1.6.7-1ubuntu2 amd64
unbound-host/bionic-updates 1.6.7-1ubuntu2.2 amd64
unbound-host/bionic-security 1.6.7-1ubuntu2.1 amd64
unbound-host/bionic 1.6.7-1ubuntu2 amd64
```

## Unbound DNS monitoring
- https://nlnetlabs.nl/documentation/unbound/howto-statistics/
- https://github.com/jeftedelima/Unbound-DNS

## unbound config examples
- https://unbound.jp/unbound/unbound-conf/

## optimization
- [NLnet Labs Documentation - Unbound - Howto Optimise](https://nlnetlabs.nl/documentation/unbound/howto-optimise/)

## dnsperf
- https://gist.github.com/i0rek/369a6bcd172e214fd791
- https://yutarommx.com/?p=318
- https://www.dns-oarc.net/tools/dnsperf
- https://kinneko.hatenadiary.org/entry/20161220/p1