require_relative 'cached_http'

class PSNet

  class_attribute :cached_http
  self.cached_http = CachedHttp.new

  RANGE_PATHS = {
    1..999     => '1-999',
    1000..1999 => '1000-1999',
    2000..2999 => '2000-2999',
    3000..3999 => '3000-3999',
    4000..5018 => '4000-5018',
  }

  BASE_URL  = 'https://prabhatasamgiita.net'
  PS_URL    = "#{BASE_URL}/lyrics/ps_%{number}.htm"
  AUDIO_URL = "#{BASE_URL}/%{range}/andromeda.php"

  def fetch number
    number = number.to_i
    range  = RANGE_PATHS.find{ |r, p| break p if r.cover? number }

    url    = PS_URL % { number: number }
    page   = cached_http.page_get url
    roman  = format_text page.at('.notranslate p').text
    trans  = format_text page.css('.lead p').last.text

    aurl     = AUDIO_URL % { range: range }
    page     = cached_http.page_get aurl
    audios   = page.css(:a).select{ |a| a.text.match(/^#{number}/) }
    audio    = audios.first.attr(:href)
    filename = cached_http.audio_get "#{BASE_URL}/#{audio}"

    SymMash.new(
      number:   number,
      url:      url,
      lyrics:   {
        roman:       roman,
        translation: trans,
      },
      filename: filename,
    )
  end

  protected

  def format_text text
    text.gsub(/\r\n\r\n/, "\n").strip
  end

end
