# PostgreSQL

## Installation
  - [MacにPostgreSQLをインストール - Qiita](https://qiita.com/_daisuke/items/13996621cf51f835494b)

## Commands
  - [PostgreSQLの基本的なコマンド - Qiita](https://qiita.com/H-A-L/items/fe8cb0e0ee0041ff3ceb)

## cache hit ratioがよくない
- まずは `postgresql.conf` まわりでtuning
  - `shared_buffers`
    - 単位: 8KB
    - 目安: 2GB以下: 全メモリの20%, 32GB以下: 全メモリの25%, 32GB以上: 8GB, 全メモリの 1/4 - 1/2
      - OSの上限値 (shmmax) を上げないと増やせないのでOSをいじれないRDSではそんなに増やせない
  - `work_mem`
    - 単位: KB
    - 目安: 最初は32MB程度から始め、log_temp_filesで吐かれたログを見つつ、倍々に増やしていく, work_mem * connection最大数 が 全メモリの1/4を超えないぐらいにしておく
  - `maintenance_work_mem`
    - 単位: KB
    - 目安: システムメモリの10%。最大1GB, もしVACUUMの問題があればもっと大きく
  - `effective_cache_size`
    - 単位: 8KB
    - 目安: 全メモリの 1/2 程度
  - ref: [PostgresのRDSチューニング - Qiita](https://qiita.com/awakia/items/9981f37d5cbcbcd155eb)

- tuneしても即座にcache_hit ratioには反映されないので，`pg_stat_reset()`を実行して統計情報をリセットする
```
zabbix=# select datname, blks_hit * 100.0 / (blks_read + blks_hit) AS cache_hit, stats_reset from pg_stat_database where datname = 'zabbix';
 datname |      cache_hit      |          stats_reset
---------+---------------------+-------------------------------
 zabbix  | 78.4450092005849089 | 2020-07-26 18:50:13.592914+09
(1 row)

zabbix=# select pg_stat_reset();
 pg_stat_reset
---------------

(1 row)

zabbix=# select datname, blks_hit * 100.0 / (blks_read + blks_hit) AS cache_hit, stats_reset from pg_stat_database where datname = 'zabbix';
 datname |      cache_hit      |          stats_reset
---------+---------------------+-------------------------------
 zabbix  | 99.8402555910543131 | 2020-08-17 08:32:21.216764+09
(1 row)
```

## References
- [PostgresのRDSチューニング - Qiita](https://qiita.com/awakia/items/9981f37d5cbcbcd155eb)
- [PostgreSQLをwarmupするツール(pg_warmup)作りました - y-asaba@hatenablog](https://y-asaba.hatenablog.com/entry/2014/02/14/221751)