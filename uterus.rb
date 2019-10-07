require 'telegram/bot'
require 'json'

secrets = JSON.parse(File.read('secrets.json'))
token = secrets['token']
channel = secrets['channel_id']

Telegram::Bot::Client.run(token) do |bot|
  botUser = bot.api.get_me()
  if botUser["ok"]
    result = botUser["result"]
    puts "success"
    puts "logged in as #{result['first_name']} (@#{result['username']}) [#{result['id']}]"
  else
    puts "failed"
    exit
  end

  bot.listen do |message|
    sender = message.from
    
    if message.chat.id == channel && !sender.is_bot && !message.text.start_with?("/")
      data = {}
      data_path = "/data/#{sender.id}.json"

      if File.file?(data_path)
        data = JSON.parse(File.read('data_path'))
      end

      words = [nil] + message.text.split + [nil]
      words[0..-2].zip(words[1..-1]) { |word,next_word|
        
      }
    end
  end
end
