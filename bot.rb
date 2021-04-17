class Bot

  def initialize token
    @token = token
  end

  def start
    Telegram::Bot::Client.run @token do |bot|
      bot.listen do |message|
        case text = message.text
        when /ps(\d+)/
          puts "bot: #{message.chat.title}: sending ps #{$1}"
          send_ps bot, message, $1
        else
          puts "bot: #{message.chat.title}: ignoring message: #{text}"
        end
      end
    end
  end

  def send_ps bot, message, number
    ps           = scraper.fetch number
    content_type = MIME::Types.type_for(ps.filename).first.content_type
    bot.api.send_audio(
      chat_id: message.chat.id,
      caption: ps.lyrics.translation,
      audio:   Faraday::UploadIO.new(ps.filename, content_type),
    )

    File.unlink ps.filename
  end

end
