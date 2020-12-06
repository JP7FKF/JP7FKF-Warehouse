# ntp

## init
  - port: udp 123

## Interactive mode
  - `ntpq`
  - ? を打つと使えるコマンドが出る．
  - `peers` で`ntpq -p` と同様の情報が得られる．
  - 抜けるときは `quit/exit`.

## サクッと確認
  - `ntpq -p`

## ntpq peers の表は何を示しているのか
- `refid`: 参照しているサーバーの更に上位のNTPサーバを示す．
- `st`: stratum番号．サーバーが第何階層目かを示す．
- `when`: 前回サーバーを参照してから経過した秒数．pollに達すれば再度参照する．
- `poll`: 参照する間隔(秒数)．
- `reach`: 過去８回の参照結果．同期した場合1，同期しなかった場合は0．8進数で表示されており，毎回同期されると377(oct)となります．つまり11111111(bin)．
- `delay`: ポーリングインターバルの遅延見積もり（単位: ミリ秒）
- `offset`: NTPサーバとのずれ(ミリ秒)
- `jitter`: NTPサーバがどのくらい正確なのかを示す指標．値が小さいほど正確．

## 時刻の同期方式
- step方式: 時刻のずれを即座に修正
- Slew方式: 時刻の進み具合をずらしていくことで、少しずつ時刻を合わせていく方式
- ntpdはSlew方式．同期までしばらく時間がかかることがある．

- システムに問題がなければ、`ntpdate [server address]` で一気に同期することも可能．
  ntpdateを使用する場合はntpdは停止している必要がある．

## ntpdate
- `ntpdate [options] <ntp_server_addr>`
- options
  - `-B`: slewモードで強制的に時刻を修正．slewモードは`adjtime()`で徐々に時刻の修正をする．
  - `-b`: stepモードで強制的に時刻を修正．stepモードは`settimeofday()`で直ぐに時刻の修正をする．
  - `-d`: debug mode.
  - `-q`: query only. 問い合わせのみを行い，時刻の修正はしない．
  - `-s`: 実行結果をsyslogに出力．
  - `-v`: verbose

## chrony
- `systemctl start chronyd`
- `/etc/chrony.conf` にntpd的なconfigを書く．フォーマットはほぼ一緒っぽい．
- `rtcsync` をconfigファイルに書いておくとハードウェアクロックも同期してくれる．
- `server <ntp_server> [options]` で参照先サーバ指定．`iburst`オプションで起動直度同期を積極的に行う．
- `chronyc sources` で`ntp -q`的なやつが観れる．

## hwclock と同期したい(manual)
- `hwclock --systohc`を叩くと現在のsystem clock がhardware clock(RTC)に同期されるっぽい．

## mac でsntp
- `sudo sntp -sS <host>`
- ex.) `sudo sntp -sS ntp.nict.jp`

## ntpdateで強制同期する．
- `-d` オプションでdebug．
```
-B: slewモードで強制的に時刻を修正．slewモードはadjtime()を使って徐々に時刻を修正．
-b: stepモードで強制的に時刻を修正．stepモードはsettimeofday()を使いすぐに時刻を修正．
-d: debug mode
-q: NTPサーバーに問い合わせのみ行う．
-s: 実行結果をsyslogに出力．
-v: verbose
```

## ntpdateのdebug
- `Server dropped: no data`
  - ntpサーバが起きてない，ntpパケットが通ってない．
- `Server dropped: strata too high`
  - ntpサーバに到達しているが，サーバがまだ利用可能ではない．syncが終わっていない．stratum値が規定外の16になっている．
- `Server dropped: Leap not in sync`
  - ntpサーバに到達しているが，当該サーバが信頼できない．due to 起動してからの時間が短い/時刻同期を実行している最中である．

## 代表的なntp
- `ntp.nict.jp`
- `ntp.jst.mfeed.ad.jp`

## hw clock
- 表示
  - `sudo hwclock`
- sync
  - `sudo hwclock --systohc`
  - `sudo hwclock --hctosys`

## ntp
- [NTP設定 - とあるSIerの憂鬱](https://incarose86.hatenadiary.org/entry/20110505/1312522379)
- [Network Time Protocol - Wikipedia](https://ja.wikipedia.org/wiki/Network_Time_Protocol)

## ntp.conf
- `tinker panic 0`
  ```
  ・panic
  panicの閾値．デフォルト1000秒／
  これを0にするとsanityチェックは行わず，
  offsetがどうなっても同期しようとする．
  ```
- `tinker step 0`
  ```
  ・step
  stepの閾値を設定．デフォルトは0.128 s
  これを0にするとstep補正を行わない．
  step補正を行わないのは-xオプションでもできる．
  ```
- `/var/lib/ntp/drift` にクロックのdriftを書いていて，ntp同期ができないときはこのclock driftをreferしてなるべく合わせようとする．

## clock source
- `cat /sys/devices/system/clocksource/clocksource0/current_clocksource`
でいまのclocksourceがみれる．
- `cat /sys/devices/system/clocksource/clocksource0/available_clocksource`
でavailableなclocksourceがみれる
- grub書き換えてrebootしてclock sourceを変える．
  `grubby --args=clocksource=hpet --update-kernel=DEFAULT`
- ex.)
```
root@hostA]# cat /sys/devices/system/clocksource/clocksource0/
available_clocksource  current_clocksource
[root@hostA]# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
tsc
[root@hostA]# cat /sys/devices/system/clocksource/clocksource0/available_clocksource
tsc hpet acpi_pm
[root@hostA]# grubby --args=clocksource=hpet --update-kernel=DEFAULT
[root@hostA]# reboot

Broadcast message from root@hostA
  (/dev/pts/0) at 7:18 ...

The system is going down for reboot NOW!
[root@hostA]# Connection to 192.168.1.1 closed by remote host.
Connection to 192.168.1.1 closed.

(...rebooted...)

[root@hostA]#
[root@hostA]# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
hpet
```
- ref.) [18.19. クロックソースの設定 Red Hat Enterprise Linux 7 | Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/system_administrators_guide/s1-configuring_clock_sources)
- TODO: clock sourceの違い

## ref
- [ntpq -pコマンドの出力メモ | 電子計算機の操縦桿](http://yeh.jp/blog/ntpq-p/)

## memo
spike_detect
clock_step
freq_mode
no_sys_peer
sudo chronyc makestep


## NTPとPTPの違いとか
- NTPはUTC(Coordinated Universal Time)基準だが，PTPはTAI(国際原子時)に基づいて時刻配信を行う．
```
国際原子時（こくさいげんしじ、フランス語: Temps Atomique International、略語：TAI、ドイツ語: Internationale Atomzeit、英語: International Atomic Time）は、現在国際的に規定・管理される原子時（原子時計によって定義される高精度で安定した時刻系）である。地球表面（ジオイド面）上の座標時の実現と位置付けられる。

国際単位系 (SI) では、「秒はセシウム133の原子の基底状態の二つの超微細準位の間の遷移に対応する放射の周期の9 192 631 770倍の継続時間である。」と定義されている[1]。
```
- `https://en.wikipedia.org/wiki/International_Atomic_Time`

```
Precision Time Protocol (PTP) は比較的新しいプロトコルであり，利用環境をLANに制限することで高精度な時刻同期を得るために作られました．PTPの仕様は IEEE-1588 として定められています． PTP では Grandmaster （GMC グランドマスタークロック， マスター）が高精度な時刻の配信を行い， スレーブが時刻を受け取ります．どのマスターをGMCとするかは，GMCA と呼ぶマスタークロック選出アルゴリズムで自動的に決定します．

PTP ではネットワークインターフェースチップのMACやPHYに実装されたハードウェアタイムスタンプ機能を使い，マイクロ秒RMS以下のタイムスタンプ精度を実現します． また誤差の要因であるネットワークの伝搬遅延を検出して補正する仕掛けを持ちます．Version 1では大規模な展開を行うためにセグメントを区切るBoundary Clock (BC)が用意されました． 現在標準とされ，EndRun製品がサポートする Version 2 では遅延管理機能を持つスイッチングハブ Transparent Clock (TC) が用意され，より柔軟で精度の高い展開が可能になりました．PTP の時刻同期精度は グランドマスタークロックやスレーブクロックのタイムスタンプ精度だけで決まるのではなく，ネットワークのトポロジー，例えばスイッチ， BC， TC やスレーブの同期能力が影響を与えます． Sonoma を含む、現在主流の PTP ハードウェアタイムスタンプをサポートする製品で構成するトポロジーは <100ns の同期も可能になっています． PTP の動作説明については，このEndRun 1588/PTP白書も参照ください．
```
- ref: [Endrun IEEE 1588 PTP グランドマスタークロック](https://www.shoshin.co.jp/c/endrun/1588ptp.html)
- ref: [vol10. PTP(Precision Time Protocol)について調べてみた - ジョンのblog](http://john-rama01.hatenablog.com/entry/2016/09/12/192536)

## systemd-timesyncdを使う
- `/etc/systemd/timesyncd.conf`
  - ここで参照先ntpサーバを指定する．
```
NTP=ntp.nict.jp
```
- `$ sudo systemctl restart systemd-timesyncd.service`
- `$ sudo systemctl status systemd-timesyncd.service`