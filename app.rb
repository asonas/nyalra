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
# ToDo: set_current_session
# ToDo: fetch credential


ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('./config/database.yml')).result)
ActiveRecord::Base.establish_connection(:production)

bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_BOT_TOKEN"], prefix: '!'


bot.message contains: 'ping' do |event|
  event.respond 'pong'
end

bot.command :setup do |event, message|
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

bot.command :add_enemy do |event, name, params|
  session_id = CurrentSession.first.session_id
  Charactor.create_enemy! session_id, name, params.gsub(" ", "")
end

Charactor.column_names.each do |col|
  bot.command "order_by_#{col}".to_sym do |event|
    cs = []
    session = CurrentSession.first.session
    session.charactors.order({ col => :desc }).each.with_index(1) do |c, i|
      cs.push "#{i} #{c.name}(#{col.upcase}:#{c.send(col)})"
    end
    event.respond "#{session.name}に登場するキャラクターの#{col.upcase}順"
    event.respond cs.join("\n")
  end
end

bot.command :current_session do |event|
  session = CurrentSession.first.session
  event.respond "session_id: #{session.id}"
  event.respond session.name
  event.respond session.url
end

bot.run
