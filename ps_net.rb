require_relative 'cached_http'

class PSNet

  class_attribute :cached_http
  self.cached_http = CachedHttp.new

  PS_URL = "https://prabhatasamgiita.net/lyrics/ps_%{number}.htm"

  def fetch number
    number = number.to_i
    url    = PS_URL % { number: number }
    page   = cached_http.page_get url
    orig   = format_text page.at('.notranslate p').text
    trans  = format_text page.css('.lead p').last.text

    SymMash.new(
      number:   number,
      lyrics:   {
        original:    orig,
        translation: trans,
      },
      #filename: filename,
    )
  end

  protected

  def format_text text
    text.gsub(/\r\n\r\n/, "\n").strip
  end

end
