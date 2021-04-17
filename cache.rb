class Cache

  class_attribute :base_path
  self.base_path  = './cache'

  class_attribute :audios_path
  self.audio_path = "#{base_path}/audios"

  class_attribute :pages_path
  self.pages_path = "#{base_path}/pages"

end
