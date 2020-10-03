# OMRON
- いいものを作ってる会社だと思う(個人の意見です)

## OMRONのUPSをRaspberry Piとzabbixで監視する．
オムロンのUPS BY50Sを持っているが，こいつはRJ45の口がなく，SNMP/syslogを用いた監視ができない．
しかしUSB-Bの口がついていて，ここからなら情報を抜くことができる．
今回はraspberry piとUPS をUSB接続し，Raspgerri Piをproxy/media converterとして利用する形でzabbixでUPSを監視してみることにする．

### 準備/前提
Raspberry Piはversion4の4Dmodelを，OSにはubuntu server 18.04を用いている．
様々なUPSの情報を取得することができるNetwork UPS Toolsというものが存在する．今回はこれを利用する．

### installation/configuration
Network UPS Toolsのinstall
```
sudo apt install nut
```
ここでUSB接続してOMRONのデバイスを探す
```
% lsusb|grep -i OMRON
Bus 001 Device 004: ID 0590:0081 Omron Corp.
```
みえた．

`/etc/nut/nut.cong` のmodeを`none`から`standalone`に変更する．
```
% sudo cat /etc/nut/nut.conf
# Network UPS Tools: example nut.conf
#
##############################################################################
# General section
##############################################################################
# The MODE determines which part of the NUT is to be started, and which
# configuration files must be modified.
#
# This file try to standardize the various files being found in the field, like
# /etc/default/nut on Debian based systems, /etc/sysconfig/ups on RedHat based
# systems, ... Distribution's init script should source this file to see which
# component(s) has to be started.
#
# The values of MODE can be:
# - none: NUT is not configured, or use the Integrated Power Management, or use
#   some external system to startup NUT components. So nothing is to be started.
# - standalone: This mode address a local only configuration, with 1 UPS
#   protecting the local system. This implies to start the 3 NUT layers (driver,
#   upsd and upsmon) and the matching configuration files. This mode can also
#   address UPS redundancy.
# - netserver: same as for the standalone configuration, but also need
#   some more network access controls (firewall, tcp-wrappers) and possibly a
#   specific LISTEN directive in upsd.conf.
#   Since this MODE is opened to the network, a special care should be applied
#   to security concerns.
# - netclient: this mode only requires upsmon.
#
# IMPORTANT NOTE:
#  This file is intended to be sourced by shell scripts.
#  You MUST NOT use spaces around the equal sign!

MODE=standalone
```

`/etc/nut/upsd.users`を編集．
```
% sudo cat /etc/nut/upsd.users
[upsmon]
password = pass
upsmon master
```

```
% sudo cat /etc/nut/upsmon.conf | egrep "^[^#]"
MONITOR by50s@localhost 1 upsmon pass master
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5
```

```
% sudo cat /etc/udev/rules.d/90-omron-ups.rules
# Omron BY50S - blazer_usb
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
ATTRS{idVendor}=="0590", ATTRS{idProduct}=="0081", \
MODE="0664", GROUP="nut", SYMLINK+="ups%n"
```
ここで SYMLINK+="ups%n"としたのがポイント．今回は同じ階層に複数のUPSをつないだので，`%n`をつけて識別できるようにしている．

```
% sudo cat /etc/nut/ups.conf | egrep "^[^#]"
[by50s]
  driver = blazer_usb
  port = /dev/ups
  desc = "Omron UPS BY50S"
  vendorid = 0590
  productid = 0081
  subdriver = ippon
  default.battery.voltage.high = 13.5
  default.battery.voltage.low = 11
```

### zabbix連携
- zabbix-agent: `nut_ups.conf`
```
UserParameter=ups.nut.battery.voltage[*],upsc $1 battery.voltage 2>/dev/null
UserParameter=ups.nut.battery.voltage.high[*],upsc $1 battery.voltage.high 2>/dev/null
UserParameter=ups.nut.battery.voltage.low[*],upsc $1 battery.voltage.low 2>/dev/null
UserParameter=ups.nut.input.frequency[*],upsc $1 input.frequency 2>/dev/null
UserParameter=ups.nut.input.voltage[*],upsc $1 input.voltage 2>/dev/null
UserParameter=ups.nut.output.voltage[*],upsc $1 output.voltage 2>/dev/null
UserParameter=ups.nut.ups.temperature[*],upsc $1 ups.temperature 2>/dev/null
UserParameter=ups.nut.ups.status[*],upsc $1 ups.status 2>/dev/null
UserParameter=ups.nut.ups.load[*],upsc $1 ups.load 2>/dev/null
```
- zabbix-server template
  - [zabbix_template_network_ups_tools.xml · GitHub](https://gist.github.com/jp7fkf/73a43820ceb224d410b28657ae407d59)

### References
- [OMRON BY50SをZabbixで監視できるようにする：びぼうろぐ：So-netブログ](https://bibo-log.blog.ss-blog.jp/2012-03-13)
- [Omron BY50S を Linux で使う (udev のイケてる設定編) - Qiita](https://qiita.com/sugi_0000/items/89c025e3804cfcfdf11e)
- [ONGS Inc.](http://www.ongs.co.jp/software/omronupsd/index.html.ja)
- [Network UPS Tools - Welcome](https://networkupstools.org/index.html)
- [Raspberry Pi と BY50S と Ready NAS の連携 – dblog](http://catoocraft.com/dblog/?p=82)
- [コタツコタ備忘録  Raspberry Piでby50sのログを取得する](http://kotatsujapan.blog.fc2.com/blog-entry-8.html)