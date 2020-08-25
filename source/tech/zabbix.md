# zabbix

## zabbixからslackにpostする
  - incoming-webhook を使う
    - slack側でurl取得を行なっておく．

  - 方針として，zabbixではmediaを使ってactionでひっかけてtriggerする感じ．
    - mediaを登録
      - 管理->メディアタイプ
      - 名前は適当，タイプはスクリプト，スクリプト名はスクリプトのファイル名．
      - scriptはzabbix directoryのalertacripts配下に置く．
        - `/usr/lib/zabbix/alertscripts/slack_notify.sh`
    - ユーザにmediaを紐づける
      - 管理->ユーザ->ユーザ(ユーザグループではない)->メディアタブ
      - 通知したいuser(通知用userでもなんでもよい)のmediaに上記mediaを紐づける．
      - ここの送信先がスクリプト呼出の第1引数になる．
    - actionの設定をする．
      - 設定->アクション->アクションの作成
      - 名前は適当，
      - 件名がスクリプトを呼ぶときの第2引数になる．
      - メッセージがまるごとスクリプトを呼ぶときの第3引数になる．
        - メッセージに乗っけるマクロの書き方とかはmanual参照
      - 実行内容はメッセージの送信で先ほど紐づけたのユーザが含まれるユーザグループや，そのユーザに送信するよう選択．次のメディアのみの使用で登録したmediaを選択．
      - その他適切に自由に実行条件等をチューンする．

      - もうひとつのやりかたとして，実行内容でリモートコマンドの実行とする手がある．

  - [GitHub - ericoc/zabbix-slack-alertscript: Zabbix AlertScript for Slack.com chat](https://github.com/ericoc/zabbix-slack-alertscript)

## 時刻監視
- [zabbix3.0でサーバ時刻のズレを監視する（うるう秒対策） - Qiita](https://qiita.com/miyahang55/items/9d1f99e9549143cdc8de)
- zabのアイテムとして下記を登録．
```
項目  値
名前  お好みで
タイプ zabbixエージェント
キー  system.localtime
データ型  数値（整数）
更新間隔  お好みで
```
- zabのトリガとして必要に応じて下記を登録
```
項目  値
名前  お好みで
条件式 {<template_name>:system.localtime.fuzzytime(<diff_threshold>)}=0
深刻度 警告（お好みで）
```

## zabbix-agentにスクリプトを叩かせる．
- 下記のような単純な構成のときに，zabbix-agentdに任意のシェルスクリプトを配置して，zabbix-serverで結果を取得したい．
```
  +------------+
  |  zabbix    |
  |   server   |
  +------------+
        |
        |
  +------------+
  | (zabbix    |
  |   proxy)   |
  +------------+
        |
        |
  +------------+
  |  zabbix    |
  |   agentd   |
  +------------+
```
1. `/var/lib/zabbix/bin/` 配下に実行したいスクリプトを配置する．(別に，ここ配下ではなくてもよい．userparamを書くときにパスを記載する．)
  - ex.) `ntpcheck.sh`
  ```
  #!/bin/sh
  /usr/sbin/ntpdate -q $1 >/dev/null ; echo $?
  ```
  - own,permissionはzabbix:zabbix(0755)程度にしておくとよさそう．
1. `/etc/zabbix/zabbix_agentd.d/` 配下にUserparamファイルを作成する．
  - 用いる機能別にファイルを分けると管理が容易だと考えられる．
  - ex.) `/etc/zabbix/zabbix_agentd.d/proxydns.conf`
  ```
  UserParameter=script.ntpcheck,HOME=/var/lib/zabbix /var/lib/zabbix/bin/ntpcheck.sh
  ```
  - ここで指定した `UserParameter=script.ntpcheck` がzabbix-serverでitem登録する際のkeyとなる．
  - あとは通常通り，zabbixにてitem登録を実施する．
  - ex.)
  ```
  Name: Proxy DNS
  Type: Zabbix Agent
  Key: script.ntpcheck
  ...
  ```
- ref.) [zabbix/独自監視の設定 - インターネットウィキ](https://kimoota.wiki.fc2.com/wiki/zabbix%2F%E7%8B%AC%E8%87%AA%E7%9B%A3%E8%A6%96%E3%81%AE%E8%A8%AD%E5%AE%9A)

## zabbix install battle
```
wget https://repo.zabbix.com/zabbix/4.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.2-1+bionic_all.deb
dpkg -i zabbix-release_4.2-1+bionic_all.deb
apt update

zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix


# vi /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=<password>

php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value max_input_vars 10000
php_value always_populate_raw_post_data -1
# php_value date.timezone Europe/Riga
Now you are ready to proceed with frontend installation steps which will allow you to access your newly installed Zabbix.

Note that a Zabbix proxy does not have a frontend; it communicates with Zabbix server only.

Agent installation
To install the agent, run

# apt install zabbix-agent

tcp/10050 port あけるとか．

https://www.zabbix.com/documentation/4.2/manual/installation/install_from_packages/debian_ubuntu
https://qiita.com/hirotaka-tajiri/items/fa8a6dbaf1ddf1b59cdd
```

## zabbix templates
- [Zabbix Share - Juniper](https://share.zabbix.com/network_devices/juniper)
- [Zabbix Share - Cisco](https://share.zabbix.com/network_devices/cisco)

## folum
- [Forums -  ZABBIX Forums](https://www.zabbix.com/forum/)

## iloの温度
```
## Critical
Title:
System-{#SNMPINDEX}: Temperature is above critical threshold
Problem:
{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()} and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}<>0 or {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{$TEMP_CRIT:"System"} and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}=0
Recovery:
{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}<{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}-3 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}<>0 or {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}<{$TEMP_CRIT:"System"}-3 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}=0

## Warning
Title:
System-{#SNMPINDEX}: Temperature is above warning threshold
Problem:
{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}*0.9 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}<>0 or {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{$TEMP_WARN:"System"}*0.9 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}=0
Recovery:
{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}<{Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}*0.9-3 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}<>0 or {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}<{$TEMP_WARN:"System"}-3 and {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureThreshold.System.{#SNMPINDEX}].last()}=0

## 簡易的には下記
### Critical
Problem: {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{$TEMP_CRIT:"System"}
Recovery: {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].max(5m)}<{$TEMP_CRIT:"System"}-3
### Warning
Problem: {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].avg(5m)}>{$TEMP_WARN:"System"}
Recovery: {Template Server HP iLO SNMPv2:sensor.temp.value[cpqHeTemperatureCelsius.System.{#SNMPINDEX}].max(5m)}<{$TEMP_WARN:"System"}-3
```

## 文字列からintegerにして圧縮する
- preprocessingを使って，ある固定文字列をstatus num的に変換する
```
Regular expression:: (.*), \1:No=0:Yes=1:Connecting=2
Regular expression:: (No|Yes|Connecting)(?=.*:\1=(\d)), \2
```
- これでNoは0に，Yesは1に，Connectingは2にそれぞれ変換される．
- これを使ってvalue mapで再度文字列するとデータ量が抑えられる．
- ref: [Getting numeric data from the item value string - ZABBIX Forums](https://www.zabbix.com/forum/zabbix-help/46332-getting-numeric-data-from-the-item-value-string)
