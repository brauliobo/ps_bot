class Cache

  class_attribute :base_path
  self.base_path   = "#{File.expand_path '../', __FILE__}/cache"

  class_attribute :audios_path
  self.audios_path = "#{base_path}/audios"

  class_attribute :pages_path
  self.pages_path  = "#{base_path}/pages"

  def self.url_to_path url
    path = CGI.unescape url
    path = url.gsub(/https?:\/\//, '').gsub('/', '-')
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
      return local_html_http.get "file://#{path}"
    end

    fetch_fill http, url, path
  end

  def self.fetch_fill http, url, path
    puts "http: fetching #{url}"
    data = http.get url
    File.write path, data.body
    data
  end

  def self.local_html_http
    local_html_http = Mechanize.new
    local_html_http.pluggable_parser.default = local_html_http.pluggable_parser['text/html']
    local_html_http
  end

end
