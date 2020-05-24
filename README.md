# Nyalra(にゃるら)

Discordで動くBotです。

キーパー（GM）の進行を手助けするのが目的で作られました。（ダイスロールなどの機能はありません）

## 使い方

``` sh
$ git clone https://github.com/asonas/nyalra
$ cd nyalra
$ bundle install
$ docker-compose up -d
$ bundle ex rake ridgepole:appky
$ export DATABASE_URL=postgresql://root:root@0.0.0.0:15432/nyalra
$ export DISCORD_BOT_TOKEN=<YOUR TOKEN>
$ export DISCORDRB_NONACL=yes
$ bundle ex ruby app.rb
```

## コマンド例

### シートを読み込む

読み込んだシートを元に現在のセッションとし定義します。

```
!setup  https://drive.google.com/#{snip}
```

`!current_session` で現在のセッションの情報を返します。

### NPCを追加する

キャラクターを追加できます。キャラクターにパラメータを付与できます。このパラメーターは以下のものを受け付けます。

* siz
* app
* str
* con
* dex
* int
* edu
* pow
* san

キャラクター名は現在のセッションにおいて一意である必要があります。

```
!add_npc キャラクター名 [パラメーター名]
!add_npc マンティコア str:90 dex:50
```


### NPCを削除する

現在のセッションに登録されているNPCを削除します。

```
!del_npc マンティコア
```

### パラメータ順に列挙します

例えば、戦闘時にDEX順を確認したいときに利用できます。

```
!order_by_dex
```

この他にも

* !order_by_siz
* !order_by_app
* !order_by_str
* !order_by_con
* !order_by_int
* !order_by_edu
* !order_by_pow
* !order_by_san

が使えます。
