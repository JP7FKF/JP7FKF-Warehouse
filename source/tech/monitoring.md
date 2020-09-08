# Monitoring
- サービス，サーバ，ネットワークの監視は奥が深い．

## 監視系Tool
### NW, Server系
- [Zabbix](https://www.zabbix.com/)
- [Cacti](https://www.cacti.net/)
- [MUNIN](http://munin-monitoring.org/)
- [MRTG](https://oss.oetiker.ch/mrtg/)

### App系
- [Datadog](https://www.datadoghq.com/)

### ログ監視
- [Fluentd](https://www.fluentd.org/)
- [swatch](https://sourceforge.net/projects/swatch/)
- [graylog](https://www.graylog.org/)
  - [Graylog2/graylog2-server: Free and open source log management](https://github.com/Graylog2/graylog2-server)
  - 裏側elasticsearchでいけるのでよさそう．
  - logを受けるフロントとGUI，アラートがセットになっている．受けたログは裏のelasticsearchにながす．
- [rsyslog](https://www.rsyslog.com/)
- [Splunk](https://www.splunk.com/)

### 可視化系
- [grafana](https://grafana.com/)
- [kibana](https://www.elastic.co/jp/products/kibana)

### チケットシステム系
- [PagerDuty](https://www.pagerduty.com/)
- [Service Now](https://www.servicenow.com/)
- [GitHub - Netflix/dispatch: All of the ad-hoc things you're doing to manage incidents today, done for you, and much more!](https://github.com/Netflix/dispatch)
  - netflixがOSS化したtool．危機管理系．jiraやpagerdutyなどの各種saas等とも連携可能らしい．

### Flow
- [GitHub - pmacct/pmacct: pmacct is a small set of multi-purpose passive network monitoring tools [NetFlow IPFIX sFlow libpcap BGP BMP RPKI IGP Streaming Telemetry].](https://github.com/pmacct/pmacct)

### Others (わからんのはとりあえずここに入れられる結末)
- [Mackerel](https://mackerel.io/ja/)
- [ThousandEyes](https://www.thousandeyes.com/)
- [Prometheus](https://prometheus.io/)
- [Nagios](https://www.nagios.org/)
- [Ichinga 2](https://icinga.com/docs/icinga2/latest/)
- [Hinemos](https://www.hinemos.info/hinemos)
- [Pandora FMS](http://pandorafms.org/ja/)
- [collectd](https://collectd.org/)
- [Elastic](https://www.elastic.co/jp/)
  - logstashとか，elasticsearchとか，kibanaとか．
  - ELKとか言いますよね．elasticstackとか．
- [fping](https://fping.org/)
  - 死活監視
- [Hatohol](http://www.hatohol.org/)
- [Sensu](https://sensu.io/)
- [New Relic](https://newrelic.com/)
- [Re:dash](https://redash.io/)
  - ダッシュボードツール
- [TICK Stack](https://www.influxdata.com/time-series-platform/)
- [Xymon](http://xymon.sourceforge.net/)
- [GitHub - netdata/netdata: Real-time performance monitoring, done right! https://my-netdata.io/](https://github.com/netdata/netdata)
  - リアルタイム性に優れる
- [Telegraf Open Source Server Agent | InfluxData](https://www.influxdata.com/time-series-platform/telegraf/)
  - [GitHub - influxdata/telegraf: The plugin-driven server agent for collecting & reporting metrics.](https://github.com/influxdata/telegraf)
- [Netdata](https://www.netdata.cloud/)

## ref
- [OSSのおすすめ監視サーバ・監視ツール比較17選 | OSSでのシステム構築・デージーネット](https://www.designet.co.jp/ossinfo/selection/monitoring-server.html)
- [手軽なメトリクス視覚化ツールを探して (Netdata, Prometheus, Telegraf) - Qiita](https://qiita.com/kikuchi_kentaro/items/8ab93b73012ee8aea717)
