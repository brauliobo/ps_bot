class Cache

  class_attribute :base_path
  self.base_path   = "#{File.expand_path '../', __FILE__}/cache"

  class_attribute :audios_path
  self.audios_path = "#{base_path}/audios"
  class_attribute :audios_compressed_path
  self.audios_compressed_path = "#{base_path}/audios_compressed"

  class_attribute :pages_path
  self.pages_path  = "#{base_path}/pages"

  def self.url_to_path url
    path = CGI.unescape url
    path = path.gsub(/https?:\/\//, '').gsub('/', '-')
    path
  end

  def self.present? path, url: nil
    present = File.exists? path
    hit     = if url then CGI.unescape url else path end
    puts "cache: hit for #{hit}" if present
    present
  end

  def self.download_audio http, url
    path = "#{audios_path}/#{url_to_path url}"
    return path if present? path, url: url

    fetch_fill http, url, path
    path
  end

  def self.download_page http, url
    path = "#{pages_path}/#{url_to_path url}"
    return local_html_http.get "file://#{path}" if present? path, url: url

    fetch_fill http, url, path
  end

  def self.fetch_fill http, url, path
    puts "http: fetching #{CGI.unescape url}"
    data = http.get url
    write path, data.body
    data
  end

  def self.write path, data
    File.write path, data
  end

  def self.local_html_http
    local_html_http = Mechanize.new
    local_html_http.pluggable_parser.default = local_html_http.pluggable_parser['text/html']
    local_html_http
  end

end
