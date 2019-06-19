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

  - https://github.com/ericoc/zabbix-slack-alertscript

## 時刻監視
- https://qiita.com/miyahang55/items/9d1f99e9549143cdc8de
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