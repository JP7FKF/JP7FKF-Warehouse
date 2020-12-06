# Ruby on Rails

## on heroku
  - [Rails3+herokuで開発はsqlite3、heroku上はPostgreSQLを使う設定](https://daipresents.com/2012/post-5016/)

## bundle install でHTTPError
```
Fetching source index from https://rubygems.org/
Retrying fetcher due to error (2/4): Bundler::HTTPError Could not fetch specs from https://rubygems.org/
Retrying fetcher due to error (3/4): Bundler::HTTPError Could not fetch specs from https://rubygems.org/^C
```
  - `gem update --system` で無事解決した．


## はじめての
```
$ rbenv -v
rbenv 1.1.1

$ rbenv install --list
$ rbenv install 2.5.0
$ rbenv global 2.5.0
$ rbenv rehash
$ ruby -v
$ bundle -v
$ mkdir ~/workspace
$ cd ~/workspace
$ rbenv local 2.5.0
$ bundle init
Gemfileを編集し# gem "rails"をコメント解除する
$ bundle install --path=vendor/bundle
$ bundle exec rails -v
$ bundle exec rails new test
$ rails server
```

## scaffoldで作成したファイルを全削除
```
rails generate scaffold "name" "field:type"〜
rails destroy scaffold "name"
rails generate scaffold
rails db:drop
rails db:create
rails db:migrate
```

## slimをぶちこむ
```
    gem 'slim-rails'
    bundle install
    gem install html2slim
    rbenv rehash
    for file in app/views/devise/**/*.erb; do erb2slim $file ${file%erb}slim && rm $file; done
```

## locale
  - i18n対応
    - `gem 'rails-i18n', '~> 5.1`
  - enum使うときにはこれがあると便利
    - `gem 'enum_help'`

  - application.rb
    ```
    # i18n
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja, :en]
    ```
  - `config/locales/` 配下に各ロケールの表記を記述する．
  - `t('jaの階層を除いたパス')` 関数を利用するとlocalesファイルの内容にあわせて各ロケールに応じたtranslationが行われる．
    - localesファイルはlocales配下にあれば特にパス指定等は必要ない．どの階層にあっても読まれるようだ．

## 問答無用でdb作り直す
  ```
    rails db:drop
    rails db:create
    rails db:migrate
  ```

## 1つのformで複数のmodelを編集したい
  - 基本的にassociationを書いておいたほうがよさそう．
  - form_forの中でfields_forをネストさせるのが定石っぽい
  - [【Rails】一つのフォームで2つのモデルを更新 - プログラミング 美徳の不幸](http://tkot.hatenablog.com/entry/2013/07/06/010617)
  - 関連がないときのベストプラクティスはこれ？(本当にこれがいいかは不明)
    ```
      def update
        if [@model1.valid?, @model2.valid?].all?
          ActiveRecord::Base.transaction do
            @model1.save
            @model2.save
          end
        else
          render :edit
        end
      end
    ```

## f.selectにclassを
- option(:include_blankや:prompt)は第3引数に設定し，html_options(classやstyle)は第4引数に設定する．
  - reference見ろって話．
- ex.) `f.select :person_id,Person.all.collect { |p| [ p.name, p.id ] }, {}, {class: 'form-control'}`
- [railsでf.selectにclassを設定する - Qiita](https://qiita.com/nakanoyoshiki/items/e87a6238f8febbeb208a)

## Dockerでrails開発をしよう
- `docker-compose run web rails new . --force --no-deps --database=postgresql --skip-bundle --api`
  - 各種railsファイルが作成される
  - `config/database.yml`にdb接続情報を書き込む．(docker-compose参照)
```
default: &default
adapter: postgresql
host: db
username: postgres
password: railstest123
# For details on connection pooling, see Rails configuration guide
# https://guides.rubyonrails.org/configuring.html#database-pooling
pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```
- `docker-compose build`
- `docker-compose run --rm api bundle exec rails webpacker:install`
- `docker-compose run --rm api rake db:create`
- `docker-compose run --rm api bundle exec rails generate controller Welcome index`
- `docker-compose up`
- `docker-compose run -rm api rake db:create db:migrate db:seed`

### references
- [Quickstart: Compose and Rails | Docker Documentation](https://docs.docker.com/compose/rails/#build-the-project)
- [kubernetesクラスタでRailsアプリを公開するチュートリアル - Qiita](https://qiita.com/tatsurou313/items/223dfa599ee5aaf6b2f0)
- [DockerでRuby on Railsの環境構築を行うためのステップ【Rails 6対応】 - Qiita](https://qiita.com/kodai_0122/items/795438d738386c2c1966)
- [Railsで超簡単API - Qiita](https://qiita.com/k-penguin-sato/items/adba7a1a1ecc3582a9c9)


## migration
- 指定できる型
```
string : 文字列(-255)
text : 長い文字列(-4294967296)
integer : 整数(2byte)
bigint: 大きな整数(4byte)
float : 浮動小数
decimal : 精度の高い小数
datetime : 日時
timestamp : タイムスタンプ
time : 時間
date : 日付
binary : バイナリ
boolean : Boolean
```
- commands
  - `$ rake db:migrate`
  - `$ rake db:rollback`
  - `$ rails generate migration クラス名`
  - `$ rails generate model モデル名`

## [Railsドキュメント](https://railsdoc.com/)


### 2020-11-22 02:24:38 Yudai Hashimoto
- [RailsでバックエンドのAPIをつくる。ついでにユーザー認証も - bokunonikki.net](https://bokunonikki.net/post/2019/0902_rails_api_user_auth/)
- [【React】＋【RailsAPI】  アプリ [3] ユーザー認証（devise/devise_token_auth/redux-token-auth）_前編｜Artefact｜note](https://note.com/artefactnote/n/n7ca736484813)
- [Ruby on RailsのAPIモードでログイン機能の実装をする - 外に出るねくら](https://kenny27.hatenablog.com/entry/2019/01/29/014725)
- [GitHub - mirego/activerecord_json_validator: ActiveRecord::JSONValidator makes it easy to validate JSON attributes against a JSON schema.](https://github.com/mirego/activerecord_json_validator)
- [Rails - DB/LDAP認証・認可をdevise,rolify,cancancanで実装する - Qiita](https://qiita.com/tatsurou313/items/0f632887d049e9503e3b)
- [Rails の UUIDプライマリキーを試す - Qiita](https://qiita.com/HeRo/items/2816e27fb3066db6c4e6)
- [Reactでリスト（配列）のFilter機能とSort機能を実装する | maesblog](https://mae.chab.in/archives/2860#post2860-6)
