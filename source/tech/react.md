# React.js

## create-react-app + Dockerで開発しよう
```
$ npx create-react-app my-app
$ cd my-app

# Dockerfileとdocker-compose.ymlをつくる．
$ cat Dockerfile
FROM node:14.5.0-alpine
WORKDIR /usr/src/app
# node versionは適宜最新のものを使うなどするのがよい．

$ cat docker-compose.yml
version: '3'
services:
  node:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./:/usr/src/app
    command: sh -c "yarn start"
    ports:
      - "3000:3000"
    stdin_open: true # https://teratail.com/questions/249875
```
- これで`docker-compose build`, `docker-compose up` とかをしつつよしなに開発する．

## Enviroment(create-react-app)
- `npm start`: development mode
- `npm run test`: test mode
- `npm run build`: production mode
- create-react-appではnodeのenvは利用できない．
  - `NODE_ENV=development`の指定で`.env.development`を読み込ませる，などはできない．

## ENV(create-react-app)
- .env : デフォルト
- .env.local: ローカル環境用(Environmentモードがtestの場合は読み込まれない)
- .env.development, .env.test, .env.production: それぞれのEnvironmentモードで読み込まれる
- .env.development.local, .env.test.local, .env.production.local: ローカル環境用
- create-react-appはdotenvを利用しており、.envファイルで指定した設定値はReactアプリ内からprocess.env経由でアクセスできます。
- .envファイルには、REACT_APP_から始まる変数名=値 の形式で記述します。
- ref: [知っていると捗るcreate-react-appの設定 - Qiita](https://qiita.com/geek_duck/items/6f99a3da15dd39658fff)

## References
- [React + Material-UIで管理画面を作成してみた | Developers.IO](https://dev.classmethod.jp/articles/react-material-ui/)
- navbarいれてととのえる
  - [【React】ルーティング設定方法 - Qiita](https://qiita.com/k-penguin-sato/items/e46725edba00013a8300)
  - [Reactで表示内容(headerとかfooterとか）のパーツ化・共通化 - Qiita](https://qiita.com/zaburo/items/082ec2b191aa466ef15f)
- [Material UIを使ってカッコいいUIのReactアプリケーションを作ってみた](https://blog.takanabe.tokyo/2015/12/material-ui%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%A6%E3%82%AB%E3%83%83%E3%82%B3%E3%81%84%E3%81%84ui%E3%81%AEreact%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%A6%E3%81%BF%E3%81%9F/)
- [react-i18nextで多言語対応（国際化・i18n）を素振り | suzukalight.com](https://suzukalight.com/2019-09-09-react-i18next/)
- [How to deploy a React app to a subdirectory | by Scott Vinkle | Medium](https://medium.com/@svinkle/how-to-deploy-a-react-app-to-a-subdirectory-f694d46427c1)
- [Reactで直接URLをたたくと404になる時の対応 - Qiita](https://qiita.com/yakipudding/items/78e68ef31e55f559c0dc)
- [文字列のリンクタグにreact-routerを適用させる方法 | 田舎エンジニアの技術ブログ | Wikiee](https://www.wikiee.com/piko/react-router-markdown)
- [知っていると捗るcreate-react-appの設定 - Qiita](https://qiita.com/geek_duck/items/6f99a3da15dd39658fff)
- [JavaScriptの行末セミコロンは省略すべきか | blog.tai2.net](https://blog.tai2.net/automatic_semilocon_insertion.html)
- [useEffect完全ガイド — Overreacted](https://overreacted.io/ja/a-complete-guide-to-useeffect/)
