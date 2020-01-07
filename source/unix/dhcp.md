# dhcp

## kea dhcp

### kea dhcp v1.5.0 install battle on ubuntu18.04
- 公式のやり方で進める．
- [Kea build on Ubuntu - Installing Kea](https://kb.isc.org/docs/kea-build-on-ubuntu)
- [Kea Administrator Reference Manual](https://downloads.isc.org/isc/kea/1.5.0/doc/kea-guide.html#install)
```
sudo apt update
sudo apt upgrade -y

## Installing with Postgres
## If you want to compile Kea with PostgreSQL, install the following packages in addition to the ones above:
## memo: ucan select cassandra instead of postgres
sudo apt -y install postgresql-server-dev-all libpq-dev

# Run configure and add --with-pgsql

## Script 1
# install the build environment
sudo apt -y install automake libtool pkg-config build-essential ccache
# install the dependencies
sudo apt -y install libboost-dev libboost-system-dev liblog4cplus-dev libssl-dev

## Script 2
wget https://ftp.isc.org/isc/kea/1.5.0/kea-1.5.0.tar.gz
tar xvfz kea-1.5.0.tar.gz
cd kea-1.5.0

export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig
# export CC="ccache gcc" CXX="ccache g++"
declare -x PATH="/usr/lib64/ccache:$PATH"
autoreconf --install
# when u use pgsql, plz add --with-pgsql options to configure cmd
# ./configure --with-pgsql=<path_to_pgsql_conf>
# mariadbなら
./configure --with-mysql=/usr/bin/mariadb_config --with-boost-include=/usr/include/boost
make -j4
sudo make install
echo "/usr/local/lib/hooks" > /etc/ld.so.conf.d/kea.conf
ldconfig
```
- `keactrl` コマンドで制御．
```
jp7fkf@dhcp:~$ keactrl status
DHCPv4 server: inactive
DHCPv6 server: inactive
DHCP DDNS: inactive
Control Agent: inactive
Kea DHCPv4 configuration file: /usr/local/etc/kea/kea-dhcp4.conf
Kea DHCPv6 configuration file: /usr/local/etc/kea/kea-dhcp6.conf
Kea DHCP DDNS configuration file: /usr/local/etc/kea/kea-dhcp-ddns.conf
Kea Control Agent configuration file: /usr/local/etc/kea/kea-ctrl-agent.conf
keactrl configuration file: /usr/local/etc/kea/keactrl.conf
```

- 2019/07現在，ubuntu18.04(bionic)では1.1.0のパッケージがある．
```
jp7fkf@lab1:~$ sudo apt list -a | grep kea
[sudo] password for jp7fkf:

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

golang-github-bgentry-speakeasy-dev/bionic 0.1.0-1 all
kea-admin/bionic 1.1.0-1build2 amd64
kea-common/bionic 1.1.0-1build2 amd64
kea-dev/bionic 1.1.0-1build2 amd64
kea-dhcp-ddns-server/bionic 1.1.0-1build2 amd64
kea-dhcp4-server/bionic 1.1.0-1build2 amd64
kea-dhcp6-server/bionic 1.1.0-1build2 amd64
kea-doc/bionic 1.1.0-1build2 all
```

## kea-ctrl-agent REST API Example
```
curl -sS -X POST -H "Content-Type: application/json" -d '{ "command": "ha-heartbeat", "service": [ "dhcp4" ] }' http://localhost:8080/ | jq
curl -sS -X POST -H "Content-Type: application/json" -d '{ "command": "lease4-get-all", "service": [ "dhcp4" ] }' http://localhost:8080/ | jq
curl -X POST -H "Content-Type: application/json" -d '{ "command": "lease4-get-all","arguments": {"subnets": [ 6 ]} ,"service": [ "dhcp4" ] }' http://localhost:8080/ | jq '.[].-sS arguments.leases[] | select (.ip-address==10.0.0.100)'
curl -sS -X POST -H "Content-Type: application/json" -d '{ "command": "config-get"}' http://localhost:8080/ | jq
curl -sS -X POST -H "Content-Type: application/json" -d '{ "command": "config-get", "service": [ "dhcp4" ] }' http://localhost:8080/ | jq
curl -sS -X POST -H "Content-Type: application/json" -d '{ "command": "lease4-del", "arguments": {"ip-address": "192.0.2.202"},  "service": [ "dhcp4" ] }' http://localhost:8080/ | jq
```

## memo
```
jp7fkf@lab1:~$ whereis boost
boost: /usr/include/boost
## boost headerはここらしいということがわかる．

mysql -uroot -p -e "show variables like "chara%";"
```

```
$ mysql -u root -p
mysql>
mysql> CREATE DATABASE database-name;
mysql> CREATE USER 'user-name'@'localhost' IDENTIFIED BY 'password';
mysql> GRANT ALL ON database-name.* TO 'user-name'@'localhost';
mysql> CONNECT database-name;
mysql> SOURCE path-to-kea/share/kea/scripts/mysql/dhcpdb_create.mysql
$ kea-admin lease-init mysql -u database-user -p database-password -n database-name
```

- [innodb_large_prefixを使ってERROR 1071を回避する | Yakst](https://yakst.com/ja/posts/734)
- ["You do not have the SUPER privilege and binary logging is enabled" Âˇ Issue #76 Âˇ soundcloud/lhm Âˇ GitHub](https://github.com/soundcloud/lhm/issues/76)
- [mysql - #1071 - Specified key was too long; max key length is 767 bytes - Stack Overflow](https://stackoverflow.com/questions/1814532/1071-specified-key-was-too-long-max-key-length-is-767-bytes)
- [DHCPサーバの２重化(failover)の設定](http://unixservermemo.web.fc2.com/sv/dhcp-failover.htm)

- [Kea High Availability vs ISC DHCP Failover - Kea DHCP](https://kb.isc.org/docs/aa-01617)
- [ISC DHCP から置き換わるであろう Kea の話し 中編 - /var/log/study](https://yaaamaaaguuu.hatenablog.com/entry/2017/12/11/112356)

- [Understanding DHCP Relay Agents | NETMANIAS](https://www.netmanias.com/en/post/techdocs/6000/dhcp-network-protocol/understanding-dhcp-relay-agents)

## dhcp lifecycle
- [Understanding the Detailed Operations of DHCP | NETMANIAS](https://www.netmanias.com/en/post/techdocs/5999/dhcp-network-protocol/understanding-the-detailed-operations-of-dhcp)

## PerfTools
- perfdhcp: [lost and found ( for me ? ): perfdhcp : DHCP stress tool](http://lost-and-found-narihiro.blogspot.com/2013/04/perfdhcp-dhcp-stress-tool.html)
- dhcperf: [DHCP 負荷試験(dhcperf) - Qiita](https://qiita.com/gzock/items/3732475ef97ee0536589)

## understanding dhcp relay
- [Understanding DHCP Relay Agents | NETMANIAS](https://www.netmanias.com/en/post/techdocs/6000/dhcp-network-protocol/understanding-dhcp-relay-agents)

## kea dhcp keynote
- https://www.isc.org/docs/getting-started-with-Kea-withQA.ppt.pdf

## kea dockerfile
- [GitHub - hrntknr/docker-kea-dhcp](https://github.com/hrntknr/docker-kea-dhcp)

## [dhtest](https://github.com/saravana815/dhtest)
- [GitHub - saravana815/dhtest: A DHCP client simulation on linux. It can simulates multiple DHCP clients behind a network device.  It can help in testing the DHCP servers or in testing switch/router by loading the device with  multiple DHCP clients.](https://github.com/saravana815/dhtest)
- [Linux dhcp client simulation tool | sargandh](https://sargandh.wordpress.com/2012/02/23/linux-dhcp-client-simulation-tool/)

## kea-anterius: kea dhcp GUI dashboard
- [GitHub - isc-projects/kea-anterius: This was a Google Summer of Code project to create a GUI dashboard for Kea. It is publicly available open source, but ISC is *not* supporting it.  The original author is unable to provide much support either, so it should be considered experimental.](https://github.com/isc-projects/kea-anterius)

## kea performance optimization
- [Kea Performance Optimization](https://kb.isc.org/docs/kea-performance-optimization)

## Load-Balancing
- KeaもMicrosoft ServerのLoad-Balancingも，act-actで動作させる場合はRFC3074に基づく場合が多いようだ．
  - [RFC 3074 - DHC Load Balancing Algorithm](https://tools.ietf.org/html/rfc3074)
  - [DHCP Failover Load Balance Mode – Microsoft Windows DNS, DHCP and IPAM Team Blog](https://blogs.technet.microsoft.com/teamdhcp/2012/08/06/dhcp-failover-load-balance-mode/)
  - これはハッシュ値に基づいて応答するサーバを選出する方式である．各サーバが自分が応答すべきハッシュリストを持っており，各サーバがDHCP Discoverを受け取ったらそれぞれのサーバでハッシュ計算を行い，自分が応答すべきハッシュリストにそのハッシュ値がある場合に応答(DHCP Offer)を送出するようだ．

## dhcplb
- [GitHub - facebookincubator/dhcplb: dhcplb is Facebook's implementation of a load balancer for DHCP.](https://github.com/facebookincubator/dhcplb)
