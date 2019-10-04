require 'telegram/bot'
require 'json'

secrets = JSON.parse(File.read('secrets.json'))
token = secrets['token']

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.logger.info('ready')

  bot.listen do |message|
    case message.text
    when '/fodasse'
      bot.api.send_message(chat_id: message.chat.id, text: "calado #{message.from.first_name}")
    end
  end
end
