require 'telegram/bot'
require 'json'

if File.file?('secrets.json')
  secrets = JSON.parse(File.read('secrets.json'))
elsif ENV["token"] != nil && ENV["channel"] != nil
  secrets = ENV
else
  puts "> no secrets were provided"
  exit
end

token = secrets["token"]
channel = secrets["channel"].to_i

Dir.mkdir("data/") unless File.exists?("data/")

puts "> logging in..."

Telegram::Bot::Client.run(token) do |bot|
  botUser = bot.api.get_me()
  if botUser["ok"]
    result = botUser["result"]
    un = "@#{result['username']}"
    puts "> success"
    puts "> logged in as #{result['first_name']} (#{un}) [#{result['id']}]\n\n"
  else
    puts "> failed"
    exit
  end

  bot.listen do |message|
    sender = message.from

    if message.chat.id == channel && !sender.is_bot && message.text != nil
      data = {}
      data_path = "data/#{sender.id}.json"

      if File.file?(data_path)
        data = JSON.parse(File.read(data_path))
      end

      if message.text.start_with?("/")
        words = message.text.split

        cmd = words[0][1..-1]
        if cmd.end_with?(un)
          cmd.slice!(un)  
        end

        args = words[1..-1]

        case cmd
        when "mimic"
          if data == {}
            bot.api.send_message(chat_id: message.chat.id, text:"sorry, i don't have any data about you yet")
          else
            word = "/s"
            sentence = []

            while word != "/e"
              count,hash = data[word]
              index = rand(1..count)
              u = 0

              hash.each { |w,c|
                if index > u && index <= u+c
                  sentence.append(w)
                  word = w
                  break
                else
                  u += c
                end
              }
            end

            bot.api.send_message(chat_id: message.chat.id, text:sentence[0..-2].join(" "))
          end
        end
      else
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
end
