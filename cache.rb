class Cache

  class_attribute :base_path
  self.base_path   = "#{File.expand_path '../', __FILE__}/cache"

  class_attribute :audios_path
  self.audios_path = "#{base_path}/audios"

  class_attribute :pages_path
  self.pages_path  = "#{base_path}/pages"

  def self.url_to_path url
    curl = url.gsub(/https?:\/\//, '').gsub('/', '-')
    path = CGI.unescape curl
    path
  end

  def self.download_audio http, url
    path  = "#{audios_path}/#{url_to_path url}"
    if File.exists? path
      puts "cache: hitting #{path}"
      return path
    end

    fetch_fill http, url, path
    path
  end

  def self.download_page http, url
    path = "#{pages_path}/#{url_to_path url}"
    if File.exists? path
      puts "cache: hitting #{path}"
      # for HTML parsing of local files
      http.pluggable_parser.default = http.pluggable_parser['text/html']
      return http.get "file://#{path}"
    end

    fetch_fill http, url, path
  end

  def self.fetch_fill http, url, path
    puts "http: fetching #{url}"
    data = http.get url
    File.write path, data.body
    data
  end

end
