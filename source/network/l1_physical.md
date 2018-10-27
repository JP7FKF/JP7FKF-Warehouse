# L1 - Physical Layer
## 物理層の話 ## 2018-09-04 09:01:41 YudaiHashimoto
  - Gigabit Ethernetは4D-PAM5という変調方式を取っている．
    - 0レベルの他に上下2レベルの信号レベルがある
    → 4-dimentional - 5-level Pulse Amplitude Modulationかと．  
    → 4Dは4-wireの意  
    → 1-wireあたり250Mbps(125Mbaud), 62.5MHzのレート  
    → シリアルの1Gbps信号を4-wireにパラレル変換している．  
    →レベル0 はForwaed Error Ditectionにのみ用いられて信号伝送には使わない  
    - 8B1Q4でシンボルを生成して4D-PAM5で送る感じ

## 1000base-tと1000base-txの違い
- UTP4Pケーブルは中に線の1ペアが4つ（8芯）ある．
- 1000Base-Tでは、1ペアが各々250Mの双方向（行って来い）の送信、受信を1ペアの中で行います。250Mの双方向で送受信×4ペアで1000Mと言う事。
- 1000Base-TXは、1ペアで各々500Mの片方向の送信のみ、受信のみを行います。500Mの送信のみ×2ペアで1000Mと500Mの受信のみ×2ペアで1000Mと言う事。
- https://lan-cables.com/txtigai.html


## イーサネットの伝送方式まとめ # 2018-08-24 17:08:02 YudaiHashimoto
- 1Gbps
  - 光ファイバー
    - 1000BASE-SX：マルチモードケーブル （550m）
    - 1000BASE-LX：マルチモードケーブル（500m前後）、シングルモードケーブル（5 - 10km前後）
  - メタルケーブル
    - 1000BASE-T：（100m）

- 10Gbps
  - 光ファイバー
    - 10GBASE-SR：マルチモード光ケーブル （300m）
    - 10GBASE-LR：シングルモード光ケーブル （10km）
  - メタルケーブル
・10GBASE-T：（100m）

- ダイレクトアタッチは10m以下．実質ラック内配線用．
- シングルモードの光ファイバは略称SMF(Single Mode Fiber)といい、光を伝送するモードフィールド径が約9μm
- マルチモードファイバはMMF(Multi Mode Fiber)といって、コア径は約50μmまたは62.5μm