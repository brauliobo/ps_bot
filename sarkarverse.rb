require_relative 'cached_http'

class Sarkarverse

  BASE_URL = 'https://sarkarverse.org'
  LISTING  = "#{BASE_URL}/wiki/List_of_songs_of_Prabhat_Samgiita"

  class_attribute :cached_http
  self.cached_http = CachedHttp.new

  class_attribute :listing
  self.listing = cached_http.page_get LISTING

  def exists? number
    !!find(number)
  end

  def find number
    number  = number.to_s.rjust 4, '0'
    row  = listing.at("tr td:first-child:contains('#{number}')")&.parent
    row
  end

  def fetch number
    row  = find number
    raise "sarkarverse: can't find with #{number}" unless row

    path = row.at(:a).attr :href
    url  = "#{BASE_URL}#{path}"
    page = cached_http.page_get url

    if lyrics = page.at('h2:contains("Lyrics") + table.wikitable')
      lyrics  = page.css('.poem').map{ |l| l.text.strip }
      lyrics  = %i[roman original translation].zip lyrics
      lyrics  = SymMash.new Hash[lyrics]
    else
      lyrics = page.at('h2:contains("Lyrics") + .poem').text.strip
      lyrics = SymMash.new translation: lyrics
    end

    aurl     = page.at('table.infobox audio').attr :src
    filename = cached_http.audio_get aurl

    SymMash.new(
      number:   number,
      url:      url,
      lyrics:   lyrics,
      filename: filename,
    )
  end

end
