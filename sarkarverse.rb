require_relative 'cached_http'
require_relative 'scraper_base'

class Sarkarverse < ScraperBase

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
    number = number.to_s.rjust 4, '0'
    listing.at("tr td:first-child:contains('#{number}')")&.parent
  end

  def fetch number
    row  = find number
    raise "sarkarverse: can't find with #{number}" unless row

    path = row.at(:a).attr :href
    url  = "#{BASE_URL}#{path}"
    page = cached_http.page_get url
    name = page.at(:h1).text.strip

    if lyrics = page.at('h2:contains("Lyrics") + table.wikitable')
      lyrics  = page.css('.poem').map{ |l| parse_text l.text }
      lyrics  = %i[roman original translation].zip lyrics
      lyrics  = SymMash.new Hash[lyrics]
    else
      lyrics = parse_text page.at('h2:contains("Lyrics") + .poem').text
      lyrics = SymMash.new translation: lyrics
    end

    audios = page.css('table.infobox audio')
    fns    = audios.map do |audio|
      aurl     = audio.attr :src
      filename = cached_http.audio_get aurl
      filename
    end

    SymMash.new(
      number:   number,
      url:      url,
      name:     name,
      lyrics:   lyrics,
      filename: fns.first,
    )
  end

end
