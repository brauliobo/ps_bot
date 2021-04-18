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
      @bot.listen do |msg|
        case msg
        when Telegram::Bot::Types::InlineQuery
          parse_number_and_send_ps msg, msg.query
        when Telegram::Bot::Types::Message
          case text = msg.text
          when '/start'
            send_help msg

          when /\/ps (\d+)$/i, /\/ps (.+)/i
            parse_number_and_send_ps msg, $1

          else
            info msg, "ignoring message: #{text}"
          end
        end
      rescue => e
        STDERR.puts "#{e.message}: #{e.backtrace.join "\n"}"
        binding.pry if ENV['PRY']
      end
    end
  end

  def send_help msg
    @bot.api.send_message(
      chat_id:    msg.chat.id,
      text:       me("To receive a PS, type /ps <number>"),
      parse_mode: 'MarkdownV2',
    )
  end

  def parse_number_and_send_ps msg, values
    refs = values.split(/[, ]/)
    refs.each do |n|
      next n.split('-').inject{ |s,e| s.to_i..e.to_i }.each do |rn|
        send_ps msg, rn
      end if n.index('-')

      send_ps msg, n
    end
  end

  def send_ps msg, number
    info msg, "sending ps #{number}"

    ps    = @scraper.fetch number
    if !ps.filename
      @bot.api.send_message(
        chat_id:    msg_orig(msg).id,
        text:       caption(ps),
        parse_mode: 'MarkdownV2',
      )
      return
    end

    # opus makes TG use voice instead
    audio = Mediazip.m4a ps.filename
    ctype = MIME::Types.type_for(audio).first.content_type
    info msg, "sending #{File.basename audio}"

    @bot.api.send_audio(
      chat_id:    msg_orig(msg).id,
      title:      ps.name,
      caption:    caption(ps),
      parse_mode: 'MarkdownV2',
      audio:      Faraday::FilePart.new(audio, ctype),
    )
  end

  def header ps
    t = "*Prabhat Samgiit ##{ps.number.to_i}: #{ps.name}*"
    t
  end

  def footer ps
    t  = "\n\n#{e ps.url}"
    t += "\n(No audio available)" if !ps.filename
    t += e "\n\nsent by @prabhatsamgiit_bot"
    t
  end

  def caption ps
    t = header ps

    t += "\n\n#{i e ps.lyrics.roman}" if ps.lyrics.roman

    # prevent caption max size (1024) error
    trans  = i e ps.lyrics.translation
    footer = footer ps
    t += if t.size + trans.size + footer.size < 950 then "\n\n#{trans}"
         else "\n\n(Translation suppressed due to Telegram limits, click the link below)" end

    t += footer ps

    me t
  end

  def info msg, out
    orig = msg_orig msg
    ctx  = if orig.respond_to? :title then orig.title else orig.username end
    puts "bot: #{ctx}: #{out}"
  end

  protected

  def msg_orig msg
    return msg.chat if msg.respond_to? :chat
    return msg.from if msg.respond_to? :from
  end

  MARKDOWN_RESERVED = %w[[ ] ( ) ~ ` > # + - = | { } . !]
  def me t
    MARKDOWN_RESERVED.each{ |c| t = t.gsub c, "\\#{c}" }
    t
  end
  def e t
    %w[* _].each{ |c| t = t.gsub c, "\\" + c }
    t
  end

  def i t
    t.split("\n").map{ |l| if l.present? then "_#{l.strip}_" else l end }.join("\n")
  end

end
