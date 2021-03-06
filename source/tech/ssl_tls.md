# SSL/TLS

## PKIと証明書，CAの話
- [【図解】よく分かるデジタル証明書(SSL証明書)の仕組み 〜https通信フロー,発行手順,CSR,自己署名(オレオレ)証明書,ルート証明書,中間証明書の必要性や扱いについて〜  |  SEの道標](https://milestone-of-se.nesuke.com/sv-advanced/digicert/digital-certification-summary/)
  - うまくまとまっている．理解しやすい．

### CA証明書の発行
- [「証明機関」による証明書の発行 (サーバー証明書を作成する) (Windows Server Tips)](https://www.ipentec.com/document/create-server-certificate-file)

### CA機関による審査（認証局による認証）
- CAは誰にでもサーバ証明書を発行するわけではなく，もちろん正当性を審査して発行する．
- 3つあるっぽい．
  - DV証明書 (Domain Validation証明書): 「対象ドメインを管理する権限があるか」ということのみを確認する．(ex. Let's Encrypt)
  - OV証明書 (Organization Validation証明書): ドメインの管理権に加え，運営組織の実在性などを電話などにより確認する．
  - EV証明書 (Extended Validation証明書): OV 証明書と同様の確認を行うが，確認方法が国際的な認定基準に基づいて行われる．加えて，ブラウザのアドレスバーが緑色になる「グリーンバー」によりそのWebサーバの安全性をよりアピールすることができる．グリーンバーには運営組織が表示される．

### SSL証明書の中身
- [SSLサーバ証明書の中身 - Q&A - SSLOFF](https://www.ssloff.com/members/knowledgebase/88/SSL.html)
  - ウェブサーバの情報（識別名（ディスティングイッシュネーム））
  - Common Name（コモンネーム）
  - Organizational Name（組織名）
  - Organizational Unit（部署名）
  - Locality（市区町村名）
  - State（都道府県名）
  - Country（国コード）
  - ウェブサーバの公開鍵
  - 証明書発行局名
  - 証明書発行局の電子署名
  - 有効期間
  - 証明書の基本情報
  - 証明書のバージョン（X.509 Ver.3など）
  - 証明書の通し番号
  - 電子署名に使われている暗号化方式

- みてみた(jp7fkf.dev)
```
% openssl s_client -connect jp7fkf.dev:443 -showcerts
CONNECTED(00000005)
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = Let's Encrypt Authority X3
verify return:1
depth=0 CN = jp7fkf.dev
verify return:1
---
Certificate chain
 0 s:/CN=jp7fkf.dev
   i:/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
-----BEGIN CERTIFICATE-----
MIIFWzCCBEOgAwIBAgISA++CwuEWR1BSNmKMMywxatI1MA0GCSqGSIb3DQEBCwUA
MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD
ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0xOTA1MjIyMTA1MDRaFw0x
OTA4MjAyMTA1MDRaMBUxEzARBgNVBAMTCmpwN2ZrZi5kZXYwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQCeakRQnNnZ10tEf4V/ruiRof90Sck4qqIZDlAn
BSC8zn6LTVJ6OaqAV0K5vNwZqtUxst4+X2dts1tSll6hx6Td+UbDdrjdwQ43Yxus
1nYJ/LmVPohVeSXVzznBIr9ejOzcuCbtzpsGDvSos/yt64299p5HH1iwTheKNtNX
k/C6dU6fcsKd4UApq8FONdZvL+2vFPeIwlBMFRdeeDzNApdmPuMmOlSV30HIHbi4
kcpkYVONil0SRAPDu5fwefewrewafeageq33tggggsdgerrfwD60fSV2PLOigVEk
Es4KMb6CAshphKm2bc/DlkuB5EMRNgNOabL3U5DXCXjBTI1VAgMBAAGjggJuMIIC
ajAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMC
MAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFDo96T5gvWjs32VLsthaNVStI/y2MB8G
A1UdIwQYMBaAFKhKamMEfd265tE5t6ZFZe/zqOyhMG8GCCsGAQUFBwEBBGMwYTAu
BggrBgEFBQcwAYYiaHR0cDovL29jc3AuaW50LXgzLmxldHNlbmNyeXB0Lm9yZzAv
BggrBgEFBQcwAoYjaHR0cDovL2fsfsfsssssssssssfsfefabmNyeXB0Lm9yZy8w
JQYDVR0RBB4wHIIKanA3ZmtmLmRldoIOd3d3LmpwN2ZrZi5kZXYwTAYDVR0gBEUw
QzAIBgZngQwBAgEwNwYLKwYBBAGC3xMBAQEwKDAmBggrBgEFBQcCARYaaHR0cDov
L2Nwcy5sZXRzZW5jcnlwdC5vcmcwggEDBgorBgEEAdZ5AgQCBIH0BIHxAO8AdgDi
aUuuJujpQAnohhu2O4PUPuf+dIj7pI8okwGd3fHb/gAAAWrhk4yaAAAEAwBHMEUC
IH9cpfJVo3HZmsxvoPtvHXrn9uDpSN2qoHbLYDjO3xbTAiEAgEsJZQwzugosRyN0
PGefe4jJg2UILjAGWBjWnYMVqL0AdQBj8tvN6DvMLM8LcoQnV2szpI1hd4+9daY4
scdoVEvYjQAAAWrhk4ybAAAEAwBGMEQCIEpmf3VR5xNU1EAuzgDbYfrKG4PYN5zF
NGSV4lC4zfIUAiAeWJ6GudNy415l2T6D0a6ib4HHlzzL4yJnD0ggXEj/NTANBgkq
hkiG9w0BAQsFAAOCAQEAWZmo694Q0Brmw5zDuWL1LB53QnUEgUSDqM7wZKKXnHH2
Z9fq1CS6ua0cG5VydfEy5XdwKWDeVgVO5PtLJnBEO9medTsunl6c6R11fMGaUsf1
Ujw+mkbYX2Bsx2nmtEPy0Y8Csa+73KJ+BCZ0ggTg+ykYPuQmtr0ERTyhkbAP/xcU
4ZspiOd3EvZ4vDt76kEyv6PF4Vn9YZic/ZCThXJFVTVURjQgFK+I6kz7sWw5v07A
DaFi0ZKzsqQccQRWdeDW0PTAzpHGO+aGylacTmsRUZ/2lx+ta8vp90562BY7wWe7
GemmuxAHMpewVRTb0GrV7VfOUukKzjTAlW6Z08vWlw==
-----END CERTIFICATE-----
 1 s:/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
   i:/O=Digital Signature Trust Co./CN=DST Root CA X3
-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxwertfgvsawtghgefavssrtywhhhfdsaww4ggTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgghrtwefbgtrh45t3refsadbh543tttsbthtgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----
---
Server certificate
subject=/CN=jp7fkf.dev
issuer=/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
---
No client certificate CA names sent
Server Temp Key: ECDH, P-384, 384 bits
---
SSL handshake has read 3230 bytes and written 350 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-CHACHA20-POLY1305
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-CHACHA20-POLY1305
    Session-ID: 050F117E22DDBEBA5ECB8104A76D6BB35DCCC5CC26B242A88C40818482B6ED36
    Session-ID-ctx:
    Master-Key: 4301520EB507D5305BB86665D3F7C2C413DDC0A4F48C227E96228D09B7B9316E5B17EDB54C0FBD0EBDCF91D1F4B35BDF
    TLS session ticket lifetime hint: 3600 (seconds)
    TLS session ticket:
    0000 - f4 96 65 45 bd 0d e6 fc-b4 4d 02 14 ee 8d b4 25   ..eE.....M.....%
    0010 - f0 79 41 bb cb cf 3a 10-fa d1 c2 36 62 56 16 45   .yA...:....6bV.E
    0020 - 68 4a ff bd ff 49 84 a5-91 db 51 42 e5 15 41 c6   hJ...I....QB..A.
    0030 - ef ec a8 fc ac d2 c4 ee-fc cc ff 85 37 1d f6 74   ............7..t
    0040 - a1 bd 23 4b 26 8d 79 bc-be 0e ac 1b 83 33 36 11   ..#K&.y......36.
    0050 - 04 17 b9 87 51 68 46 68-2a 90 05 3c ba b5 86 5a   ....QhFh*..<...Z
    0060 - 7b 0e d8 99 c3 6a 54 05-e0 6f b8 fb 87 d9 d5 b0   {....jT..o......
    0070 - 81 44 a4 d1 19 f3 13 77-e4 2f 2f e6 c0 93 fc 25   .D.....w.//....%
    0080 - 49 64 f0 d4 91 7f 45 16-fb 4e d4 69 ff 8e 77 7e   Id....E..N.i..w~
    0090 - 76 23 8b 06 fa cf 91 74-f4 e5 de 5a a5 6f 7c f7   v#.....t...Z.o|.

    Start Time: 1562073404
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
---
closed
```
- 頭に「s」がついているのがその証明書の情報，「i」がついているのがその証明書の発行者の情報らしい．subjectとissuerだな．

## 証明書失効リスト（しょうめいしょしっこうリスト、英: Certificate Revocation List, CRL）
- 証明書が失効した公開鍵のシリアル番号のリスト．
- これに記載のある証明書は失効済みなので信頼できない．
  - `Revoked`: 失効
  - `Hold`: 停止
  の2パターンがあり，失効は再び利用はできないが，停止状態であれば失効リストから削除されて有効に戻すことができる．

## Certificate Signing Request(CSR)
- 証明書発行リクエスト．
- 公開鍵，コモンネーム（FQDN），組織名，部署名等が含まれる．
- これらを`ディスティングイッシュネーム情報`と呼ぶ．
- `openssl req -in <csr_file> -text` で確認できる．

## プライベート認証局(root ca, intermediate ca)
- [OpenSSLでプライベート認証局の構築（ルートCA、中間CA） - Qiita](https://qiita.com/haruca_tech/items/ac5ece9618a613f37ce5)

## wildcard 証明書 - SSL
- [完全無料でワイルドカード証明書を手に入れよう / How to get wildcard certs without any charges - Speaker Deck](https://speakerdeck.com/kenojiri/how-to-get-wildcard-certs-without-any-charges)