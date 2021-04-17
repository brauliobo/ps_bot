require_relative 'cached_http'

class Sarkarverse

  BASE_URL   = 'https://sarkarverse.org'
  PS_LISTING = "#{BASE_URL}/wiki/List_of_songs_of_Prabhat_Samgiita"

  class_attribute :cached_http
  self.cached_http = CachedHttp.new

  def ps_listing
    @ps_listing ||= cached_http.page_get PS_LISTING
  end

  def exists? number
    !!find(number)
  end

  def find number
    number  = number.to_s.rjust 4, '0'
    ps_row  = ps_listing.at("tr td:first-child:contains('#{number}')")&.parent
    ps_row
  end

  def fetch number
    ps_row  = find number
    raise "sarkarverse: can't find with #{number}" unless ps_row

    ps_link = ps_row.at(:a).attr :href
    ps_page = cached_http.page_get ps_link

    if lyrics = ps_page.at('h2:contains("Lyrics") + table.wikitable')
      lyrics  = lyrics.css(:tr).to_a.second
      lyrics  = lyrics.css(:td).map{ |l| l.text }
      lyrics  = [:roman, :original, :translation].zip lyrics
      lyrics  = SymMash.new Hash[lyrics]
    else
      lyrics = ps_page.at('h2:contains("Lyrics") + .poem').text
      lyrics = SymMash.new translation: lyrics
    end

    url      = ps_page.at('table.infobox audio').attr :src
    filename = cached_http.audio_get url

    SymMash.new(
      number:   number,
      lyrics:   lyrics,
      filename: filename,
    )
  end

end
