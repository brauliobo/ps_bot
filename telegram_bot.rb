class TelegramBot

  def initialize token
    @token   = token
    @scraper = Scraper.new
  end

  def start
    Telegram::Bot::Client.run @token do |bot|
      bot.listen do |message|
        case text = message.text
        when /\/ps (\d+)/
          puts "bot: #{message.chat.title}: sending ps #{$1}"
          send_ps bot, message, $1
        else
          puts "bot: #{message.chat.title}: ignoring message: #{text}"
        end
      end
    end
  end

  def send_ps bot, message, number
    ps           = @scraper.fetch number
    content_type = MIME::Types.type_for(ps.filename).first.content_type
    bot.api.send_audio(
      chat_id:    message.chat.id,
      caption:    caption(ps),
      parse_mode: 'MarkdownV2',
      audio:      Faraday::UploadIO.new(ps.filename, content_type),
    )

    File.unlink ps.filename
  end

  def caption ps
    t  = "*Prabhat Samgiit #{ps.number.to_i}*"
    t += "\n\n#{i e ps.lyrics.roman}" if ps.lyrics.original
    t += "\n\n#{i e ps.lyrics.translation}"
    t += "\n\n#{e ps.url}"
    caption_escape t
  end

  protected

  def caption_escape t
    %w[( ) .].each{ |c| t.gsub! c, "\\#{c}" }
    t
  end

  def i t
    t.split("\n").map{ |l| if l.present? then "_#{l}_" else l end }.join("\n")
  end

  def e t
    %w[* _].each{ |c| t.gsub! c, "\\#{c}" }
    t
  end

end
