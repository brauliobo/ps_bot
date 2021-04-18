class ScraperBase

  def fetch
    raise 'not implemented'
  end

  def parse_text text
    text.gsub!(/\r\n/, "\n")
    text.gsub!(/\r/, "\n")
    text.gsub!(/\n\n/, "\n")
    text.strip!

    if text.size > 512
      # reduce duplicated lines to avoid 1024 caption limit
      parags = text.split("\n\n")
      text   = parags.map do |p|
        lines = p.split("\n")
        lines.map!.with_index{ |t,i| if t.blank? then "BLANK#{i}" else t end }
        lines.uniq!
        lines.map!{ |t,i| if t.starts_with? 'BLANK' then '' else t end }
        lines.join("\n")
      end.join("\n\n")
    end

    text
  end

end
