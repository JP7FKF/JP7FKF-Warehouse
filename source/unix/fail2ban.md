# fail2ban

## [Fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page)

## commands
- statusをみる
  - `fail2ban-client status <name(optional)>`
- unban
  - `fail2ban-client set <jail_name> unbanip <ip_addr>`

## fail2ban battle on ubuntu 18.04
```
$ sudo apt install fail2ban

$ sudo ls /etc/fail2ban
action.d       fail2ban.d  jail.conf  paths-arch.conf  paths-debian.conf
fail2ban.conf  filter.d    jail.d     paths-common.conf  paths-opensuse.conf

## fail2ban.confはdaemon自体の全般設定系．基本いじらなくてもよさそう．
## jail系はjailにいれる条件等を記載する．filterはsyslogやdarmonをベースのフィルタし，条件にマッチするか否かを判定するロジックを構成する．actionはjailに入った場合のaction等を設定する．
## つまりjailのconfigで書かれたfilter, actionがあり，filterに存在する条件に(logが)マッチし，jailに書かれたしきい値等の条件を超えたらactionを実施する．というのがが大まかな流れ．

# common-configをする
# jail.confは直接編集せず，jail.local等をjail.confからcpして編集する

$ sudo cp /etc/fail2ban/jail.conf  /etc/fail2ban/jail.local
```

### 下記は設定例
- `/etc/fail2ban/jail.local`
```
[INCLUDES]
before = paths-debian.conf

[DEFAULT]
ignorecommand =
bantime  = 10m
findtime  = 10m
maxretry = 5
backend = auto
usedns = no
logencoding = auto
enabled = false
mode = normal
filter = %(__name__)s[mode=%(mode)s]

destemail = root@localhost
sender = root@<fq-hostname>
mta = sendmail

# Default protocol
protocol = tcp
chain = <known/chain>
port = 0:65535
fail2ban_agent = Fail2Ban/%(fail2ban_version)s
banaction = iptables-multiport
```

- `/etc/fail2ban/fail.d/sshd.conf`
```
# SSH servers

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry= 3
```

- ちなみに `/etc/fail2ban/jail.d/defaults-debian.conf`
```
[sshd]
enabled = true
```
もとからsshdはenabledになっているっぽい．

- banされると(ex. 192.168.0.10のクライアントがsshのパスワード認証で3回失敗した場合)
```
$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 3
|  `- File list:  /var/log/auth.log
`- Actions
   |- Currently banned: 1
   |- Total banned: 1
   `- Banned IP list: 192.168.0.10

$ sudo iptables -nvL
Chain INPUT (policy ACCEPT 5778 packets, 2444K bytes)
 pkts bytes target     prot opt in     out     source               destination
   51  4892 f2b-sshd   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport dports 22

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 5814 packets, 2321K bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain f2b-sshd (1 references)
 pkts bytes target     prot opt in     out     source               destination
   31  3504 REJECT     all  --  *      *       192.168.0.10          0.0.0.0/0            reject-with icmp-port-unreachable
   20  1388 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```
- `f2b-<name>` というchainでbanされている．これは `/etc/fail2ban/action.d/iptables-multiport.conf` に記載されている通りだ．

## 再犯者への刑
- `/etc/fail2ban/filter.d/recidive.conf`
このようなfilterがあるので
```
# Fail2Ban filter for repeat bans
#
# This filter monitors the fail2ban log file, and enables you to add long
# time bans for ip addresses that get banned by fail2ban multiple times.
#
# Reasons to use this: block very persistent attackers for a longer time,
# stop receiving email notifications about the same attacker over and
# over again.
#
# This jail is only useful if you set the 'findtime' and 'bantime' parameters
# in jail.conf to a higher value than the other jails. Also, this jail has its
# drawbacks, namely in that it works only with iptables, or if you use a
# different blocking mechanism for this jail versus others (e.g. hostsdeny
# for most jails, and shorewall for this one).

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = fail2ban\.actions\s*

# The name of the jail that this filter is used for. In jail.conf, name the
# jail using this filter 'recidive', or change this line!
_jailname = recidive

failregex = ^(%(__prefix_line)s| %(_daemon)s%(__pid_re)s?:\s+)NOTICE\s+\[(?!%(_jailname)s\])(?:.*)\]\s+Ban\s+<HOST>\s*$

ignoreregex =

[Init]

journalmatch = _SYSTEMD_UNIT=fail2ban.service PRIORITY=5

# Author: Tom Hendrikx, modifications by Amir Caspi
```
これを適用すればよい．
```
# /etc/fail2ban/fail.d/recidive.local
[recidive]

enabled  = true
filter   = recidive
logpath  = /var/log/fail2ban.log
action   = iptables-allports[name=recidive]
           sendmail-whois-lines[name=recidive, logpath=/var/log/fail2ban.log]
bantime  = 604800  ; 1 week
findtime = 86400   ; 1 day
maxretry = 5
```
この場合たとえば1日5回fail2banされたら1week banが継続することになる．

## unbanする
typo等でbanされてしまった場合など．
```
$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 6
|  `- File list:  /var/log/auth.log
`- Actions
   |- Currently banned: 1
   |- Total banned: 2
   `- Banned IP list: 192.168.0.10
$ sudo fail2ban-client unban 192.168.0.10
1
$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 6
|  `- File list:  /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned: 2
   `- Banned IP list:
```

## References
- [Ubuntu 18.04 LTS iptables Fail2ban 設定等 | ひかるLOG](https://bellett.moe.hm/index.php/2018/08/15/ubuntu-18-04-lts-iptables-fail2ban/)
- [fail2banでしつこい攻撃者だけ長期BANする方法 | TeraDas](https://www.teradas.net/archives/15002/)
- [fail2banでdirectory traversalなwebアクセスを蹴る - Qiita](https://qiita.com/mrmt/items/00e1cc86b8406dd4e8ab)
