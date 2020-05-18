require 'discordrb'

bot = Discordrb::Bot.new token: ENV{"DISCORD_BOT_TOKEN"}

# ToDo
# setup Dockerfile
# ridgepole
# create schema
# create model
#  - Charactor
#  - Sessions

bot.message(with_text: 'ping') do |event|
  event.respond 'pong'
end

bot.run
