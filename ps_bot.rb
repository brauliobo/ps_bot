require 'bundle/setup'

TOKEN      = ENV['TOKEN']
PS_LISTING = 'https://sarkarverse.org/wiki/List_of_songs_of_Prabhat_Samgiita'

def http
  @http ||= Mechanize.new
end
def ps_listing
  @ps_listing ||= http.get PS_LISTING
end

if ps_number = ARGV[0] then pp parse ps_number end

def send_ps bot, message, number
  ps           = parse number
  content_type = MIME::Types.type_for(ps.filename).first.content_type
  bot.api.send_audio(
    chat_id: message.chat.id,
    caption: ps.lyrics.translation,
    audio:   Faraday::UploadIO.new(ps.filename, content_type),
  )

  File.unlink ps.filename
end

Telegram::Bot::Client.run TOKEN do |bot|
  bot.listen do |message|
    case text = message.text
    when /ps(\d+)/
      puts "#{message.chat.title}: sending ps #{$1}"
      send_ps bot, message, $1
    else
      puts "#{message.chat.title}: ignoring message: #{text}"
    end
  end
end

