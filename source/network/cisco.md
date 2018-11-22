# Cisco commands
## username password の数字の意味
username 'hoge' password 0 'pass' -> この0の意味はなんなのか？
→0は暗号化してない．7はcisco独自の暗号化方式によってencryptされていることを示している．

## Cisco IOS XE, IOS XR: how to check optical power
- IOS XE example:
  - `show interfaces tenGigabitEthernet 1/1/4 transceiver`

- IOS XR example:
  - `show controllers tenGigE 0/0/2/1 phy`
  - `show controllers dwdm 0/0/2/1 optics`

### よく書くACL
  ```
  ip access-list extended firewall-in-v4
    remark DNS
    deny   udp any any eq domain
    remark NTP
    permit udp any eq ntp x.x.x.x 0.0.0.255 eq ntp
    permit udp any eq ntp x.x.x.x 0.0.0.255 eq ntp
    deny   udp any eq ntp any eq ntp
    remark SNMP
    deny   udp any any eq snmp
    remark SSDP
    deny   udp any any eq 1900
    remark NetBIOS
    deny   tcp any any eq msrpc
    deny   tcp any any eq 137
    deny   tcp any any eq 138
    deny   tcp any any eq 139
    deny   tcp any any eq 445
    deny   udp any any eq 135
    deny   udp any any eq netbios-ns
    deny   udp any any eq netbios-dgm
    deny   udp any any eq netbios-ss
    deny   udp any any eq 445
    remark Bogon
    deny   ip 0.0.0.0 0.255.255.255 any
    deny   ip 10.0.0.0 0.255.255.255 any
    deny   ip 100.0.0.0 0.65.255.255 any
    deny   ip 127.0.0.0 0.255.255.255 any
    deny   ip 169.254.0.0 0.0.255.255 any
    deny   ip 172.16.0.0 0.15.255.255 any
    deny   ip 192.168.0.0 0.0.255.255 any
    deny   ip 198.51.100.0 0.0.0.255 any
    deny   ip 203.0.113.0 0.0.0.255 any
    deny   ip 240.0.0.0 15.255.255.255 any
    deny   ip host 255.255.255.255 any
    remark MyPrefix
    deny   ip x.x.x.x x.x.x.x x.x.x.x x.x.x.x
    deny   ip x.x.x.x x.x.x.x x.x.x.x x.x.x.x
    permit ip any any
  ```

### DNS サーバを動かす
  ```
  ip dns server
  ip host www.example.local 192.168.0.1
  ip dns primary example.local soa dns01.example.local root.example.local 3600 900 86400 3600
  ```
  - こんな感じでレコードをつっこむ．