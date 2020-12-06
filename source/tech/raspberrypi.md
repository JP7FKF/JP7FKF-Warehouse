# Raspberry pi

## モデルとか確認する
```
## version 確認
$ lsb_release -a

## kernel 確認
$ uname -a

## raspberry piハードウェアのモデルを確認する方法
$ cat /proc/device-tree/model
```

## おまじない
- [Raspberry PiのSDカードが壊れた！寿命を延ばす方法 5+1選!【運用編を追加】 | IoT PLUS](https://iot-plus.net/make/raspi/extend-sdcard-lifetime-5plus1/)

## GNSS Stratum1 NTP

### References
- [Raspberry Pi + GPS ModuleでStratum1なNTPサーバをつくる](tech/raspintp.md)
- [#2 Raspberry Piで作るStratum1 NTPサーバをベランダで動かすまで - 猫にジャズ](https://notchi.hatenablog.jp/entry/2019/05/06/165659)
- [NMEA 0183 sentences データ解析 – piyajk.com](https://piyajk.com/archives/302)
- [GitHub - MartijnBraam/gpsd-py3: Python 3 GPSD client](https://github.com/MartijnBraam/gpsd-py3)

### きのこアンテナ
- HP Symmetricom 58532A
- [58532A | eBay](https://www.ebay.com/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw=58532A&_sacat=0&LH_TitleDesc=0&_osacat=0&_odkw=symmetricom+58532A&LH_TitleDesc=0)

## SDカードへのwriteを減らす取り組み

### swapとめる
- raspbian
```
sudo systemctl status dphys-swapfile.service
sudo systemctl stop dphys-swapfile.service
sudo systemctl disable dphys-swapfile.service
```
- ubuntu
```
% sudo swapoff -a
% free
              total        used        free      shared  buff/cache   available
Mem:        3882424      275812     2606140        4088     1000472     3546192
Swap:             0           0           0
# あと/etc/fstab みておけばいい
```

### ramdisk
```
# /etc/fstab
# tmpfile
tmpfs /tmp     tmpfs defaults,size=64m,noatime,mode=1777  0       0
tmpfs /var/tmp tmpfs defaults,size=32m,noatime,mode=1777  0       0
# /var/log
tmpfs /var/log tmpfs defaults,size=64m,noatime,mode=0755  0       0
```
```
$ sudo rm -rf /tmp
$ sudo rm -rf /var/tmp
$ sudo shutdown -r now
$ df -h
```

### /etc/rsyslog.conf をいいかんじに
- 必要なものだけだそうな．

### 起動時にlog directoryをつくる
```
$ cat /etc/rc.local
#!/bin/sh -e
# for ramdisk
mkdir -p /var/log/zabbix-agent/
chown zabbix:zabbix /var/log/zabbix-agent/

exit 0
```
- [【新旧対応】Linuxでの自動起動の設定方法を解説](https://eng-entrance.com/linux_startup)

- ubuntu20くらいでやるときはrclocal serviceを作る必要あり
  - `sudo systemctl daemon-reload` とか `sudo systemctl enable rc-local` とか `sudo chmod +x /etc/rc.local` とか基本的なことをわすれずにやる
  - `sudo vim /etc/systemd/system/rc-local.service`
```
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
```

### crontabにこんな感じでかくと起動時に実行する．
```
@reboot /bin/sh /home/jp7fkf/cmd_boot.sh
```