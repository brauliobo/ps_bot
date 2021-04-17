class Cache

  class_attribute :base_path
  self.base_path   = './cache'

  class_attribute :audios_path
  self.audios_path = "#{base_path}/audios"

  class_attribute :pages_path
  self.pages_path  = "#{base_path}/pages"

  def self.download_audio http, url
    audio   = http.get url
    fn      = "#{audios_path}/#{CGI.unescape audio.filename}"
    File.write fn, audio.body
    fn
  end

end
