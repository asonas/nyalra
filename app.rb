require 'discordrb'

require 'active_record'
require './lib/models/charactor'
require './lib/models/session'
require './lib/models/current_session'
require './lib/models/spreadsheet_client'
require 'pry'
require 'erb'

# ToDo: error handling
# ToDo: update

ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('./config/database.yml')).result)
ActiveRecord::Base.establish_connection(:production)


bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_BOT_TOKEN"], prefix: '!'

bot.message contains: 'ping' do |event|
  event.respond 'pong'
end

desc = "アイロン卓のSpreadsheetに `csv` というシートからいい感じにキャラクターを読み込みます。この時に読まれたSpreadsheetを現在のセッションとして扱います。"
usage = "!setup https://docs.google.com/spreadsheets/d/15kAbGZYsSN3rlMt-RNi4Xg91AsFtYR9tFILYOXVc3a4/edit"
bot.command :setup, description: desc, usage: usage do |event, message|
  url = message.match %r{https?://[\w_.!*\/')(-]+}

  unless url
    event.send_message("URL見つかんない")
  else
    event.send_message "OK, 読む"

    client = SpreadsheetClient.new(url.to_s)
    client.save_charactor_to_csv

    ActiveRecord::Base.transaction do
      response = client.get_spreadsheet

      session = Session.create!(
        name: response.properties.title,
        url: response.spreadsheet_url
      )
      CurrentSession.destroy_all
      CurrentSession.create!(session_id: session.id)

      Charactor.load_from_csv!(session.id)
    end

    session = CurrentSession.first.session
    event.respond "読んだ: #{session.name}"
    event.respond session.url
    event.respond session.all_charactors.join("\n")
  end
end

def show_charactor
  cs = []
  CurrentSession.first.session.charactors.each do |c|
    prefix = if c.npc
      "[NPC]"
    else
      "[PC]"
    end
    cs.push "#{prefix} #{c.name}"
  end
  cs
end

desc = "現在のセッションに登録されているキャラクターをすべて表示します。"
bot.command :show_chara, description: desc do |event|
  cs = show_charactor
  event.respond cs.join("\n")
end

bot.command :show_char, description: desc do |event|
  cs = show_charactor
  event.respond cs.join("\n")
end

bot.command :add_npc, description: "NPCをパラメーター付きで追加できます。", usage: "!add_npc <キャラ名> dex:65 str:50" do |event, name, params|
  begin
    session_id = CurrentSession.first.session_id
    c = Charactor.create_npc! session_id, name, params&.gsub(" ", "")
    event.respond "#{c.name}を追加したよ"
  rescue ActiveRecord::RecordInvalid => e
    event.respond "すでに登録されてるっぽい"
  end
end

bod.comand :update_npc, description: "NPCのパラメーターを更新できます。（同じパラメーターを指定した場合は上書きされます）", usage: "!update_npc <キャラ名> dex:55" do |event, name, params|
  begin
    session_id = CurrentSession.first.session_id
    charactor = Charactor.find_by(session_id, name, npc: true)
    charactor.update_parameter(params)
    event.respond "#{c.name}を更新したよ"
  rescue ActiveRecord::RecordInvalid => e
    event.respond e
  end
end

bot.command :del_npc, description: "追加しているNPCを削除できます。", usage: "!del <キャラ名>" do |event, raw_name|
  name = raw_name.strip
  message = []
  ActiveRecord::Base.transaction do
    c = CurrentSession.first.session.charactors.where(npc: true).where(name: name).first
    if c
      message.push "#{c.name}"
      c.destroy!
      message.push "削除したよ"
    else
      message.push "名前が #{name} の敵は見つからなかったよ"
    end
  end

  event.respond message.join("\n")
end

Charactor.column_names.each do |col|
  bot.command "order_by_#{col}".to_sym, description: "キャラクターを#{col}順に列挙できます。" do |event|
    cs = []
    session = CurrentSession.first.session
    session.charactors.order({ col => :desc }).each.with_index(1) do |c, i|
      cs.push "#{i} #{c.name}(#{col.upcase}:#{c.send(col)})"
    end
    event.respond "#{session.name}に登場するキャラクターの#{col.upcase}順"
    event.respond cs.join("\n")
  end
end

bot.command :current_session, description: "現在のセッションの情報を表示します" do |event|
  session = CurrentSession.first.session
  event.respond "session_id: #{session.id}"
  event.respond session.name
  event.respond session.url
end

bot.command :help do |event|
  message = []
  bot.commands.each do |command, a|
    attr = a.attributes
    message.push "**#{command}**"
    message.push attr[:description]
    message.push "使い方: `#{attr[:usage]}`" if attr[:usage]
  end

  event.respond "その他細かい話はこちら: https://scrapbox.io/ironing/Nyalrathotep"

  event.respond message.join("\n")
end

bot.command :revision do |event|
  event.respond `git rev-parse HEAD`
end

bot.run
