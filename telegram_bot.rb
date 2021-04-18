require_relative 'mediazip'

class TelegramBot

  def initialize token
    @token   = token
    @scraper = Scraper.new
  end

  def start
    Telegram::Bot::Client.run @token do |bot|
      puts "bot: started, listening"
      @bot = bot
      @bot.listen do |message|
        case text = message.text
        when '/start'
          send_help message

        when /\/ps (\d+)$/i
          send_ps message, $1

        when /\/ps (.+)/i
          refs = $1.split(/[, ]/)
          refs.each do |n|
            next n.split('-').inject{ |s,e| s.to_i..e.to_i }.each do |rn|
              send_ps message, rn
            end if n.index('-')

            send_ps message, n
          end
        else
          info message, "ignoring message: #{text}"
        end
      end
    end
  end

  def send_help message
    @bot.api.send_message(
      chat_id:    message.chat.id,
      text:       me("To receive a PS, type /ps <number>"),
      parse_mode: 'MarkdownV2',
    )
  end

  def send_ps message, number
    info message, "sending ps #{$1}"

    ps    = @scraper.fetch number
    if !ps.filename
      @bot.api.send_message(
        chat_id:    message.chat.id,
        text:       caption(ps),
        parse_mode: 'MarkdownV2',
      )
      return
    end

    # opus makes TG use voice instead
    audio = Mediazip.m4a ps.filename
    ctype = MIME::Types.type_for(audio).first.content_type
    info message, "sending #{File.basename audio}"

    @bot.api.send_audio(
      chat_id:    message.chat.id,
      title:      ps.name,
      caption:    caption(ps),
      parse_mode: 'MarkdownV2',
      audio:      Faraday::FilePart.new(audio, ctype),
    )
  end

  def caption ps
    t  = "*Prabhat Samgiit ##{ps.number.to_i}: #{ps.name}*"
    t += "\n\n#{i e ps.lyrics.roman}" if ps.lyrics.roman

    # prevent caption max size (1024) error
    trans = i e ps.lyrics.translation
    t += if t.size + trans.size < 900 then "\n\n#{trans}"
         else "\n\n(Translation suppressed due to Telegram limits, click the link below)" end

    t += "\n\n#{e ps.url}"
    t += "\n(No audio available)" if !ps.filename
    me t
  end

  def info message, out
    puts "bot: #{message.chat.title}: #{out}"
  end

  protected

  MARKDOWN_RESERVED = %w[[ ] ( ) ~ ` > # + - = | { } . !]

  def me t
    MARKDOWN_RESERVED.each{ |c| t.gsub! c, "\\#{c}" }
    t
  end
  def e t
    %w[* _].each{ |c| t.gsub! c, "\\#{c}" }
    t
  end

  def i t
    t.split("\n").map{ |l| if l.present? then "_#{l}_" else l end }.join("\n")
  end

end
