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
    puts "logged in as #{result['first_name']} (@#{result['username']}) [#{result['id']}]\n"
  else
    puts "failed"
    exit
  end

  bot.listen do |message|
    sender = message.from

    if message.chat.id == channel && !sender.is_bot && message.text != nil && !message.text.start_with?("/")
      data = {}
      data_path = "data/#{sender.id}.json"

      if File.file?(data_path)
        data = JSON.parse(File.read(data_path))
      end

      words = ["/s"] + message.text.split + ["/e"]
      words[0..-2].zip(words[1..-1]) { |word,next_word|
        count, hash = 0, {}

        if data.key?(word)
          count, hash = data[word]
        end

        if !hash.key?(next_word)
          hash[next_word] = 0
        end

        count += 1
        hash[next_word] += 1
      
        data[word] = count, hash
      }

      File.open(data_path, "w") { |f|
        f.write(data.to_json)
        f.flush
      }
    end
  end
end
