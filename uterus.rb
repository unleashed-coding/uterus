require 'telegram/bot'
require 'json'

secrets = JSON.parse(File.read('secrets.json'))
token = secrets['token']

Telegram::Bot::Client.run(token) do |bot|
  # botUser = bot.getMe()
  # print "logged in as {botUser.first_name} {botUser.last_name} (@{botUser.username}) [{botUser.id}]"

  bot.listen do |message|
    if message.chat.id == -1001451190298
      # reee
    end
  end
end
