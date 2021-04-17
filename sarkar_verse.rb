class SarkarVerse

  def parse number
    number  = number.to_s.rjust 4, '0'
    ps_row  = ps_listing.at("tr td:first-child:contains('#{number}')").parent
    ps_link = ps_row.at(:a).attr :href
    ps_page = http.get ps_link

    if lyrics = ps_page.at('h2:contains("Lyrics") + table.wikitable')
      lyrics  = lyrics.css(:tr).to_a.second
      lyrics  = lyrics.css(:td).map{ |l| l.text }
      lyrics  = [:roman, :original, :translation].zip lyrics
      lyrics  = Hashie::Mash.new Hash[lyrics]
    else
      lyrics = ps_page.at('h2:contains("Lyrics") + .poem').text
      lyrics = Hashie::Mash.new translation: lyrics
    end

    audio   = ps_page.at('table.infobox audio').attr :src
    audio   = http.get audio
    fn      = "/tmp/#{CGI.unescape audio.filename}"
    File.write fn, audio.body

    Hashie::Mash.new(
      number:   number,
      lyrics:   lyrics,
      filename: fn,
    )
  end

end
