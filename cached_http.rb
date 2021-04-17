require_relative 'cache'

class CachedHttp

  attr_reader :mechanize

  def initialize
    @mechanize = Mechanize.new
  end

  def page_get url
    Cache.download_page @mechanize, url
  end

  def audio_get url
    Cache.download_audio @mechanize, url
  end

end
