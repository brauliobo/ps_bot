require 'shellwords'
require_relative 'cache'

class Mediazip

  BITRATE = 64
  COMMAND = <<-EOC
    ffmpeg -loglevel quiet -i %{input} -f wav - |
    opusenc --bitrate #{BITRATE} --quiet - %{output}
  EOC

  def self.compressed_path audio
    comp = File.basename audio.sub(/.[^\.]+$/, '.opus')
    comp = "#{Cache.audios_compressed_path}/#{comp}"
    comp
  end

  def self.zip audio
    comp = compressed_path audio
    return comp if Cache.present? comp

    cmd  = COMMAND % {
      input:  Shellwords.escape(audio),
      output: Shellwords.escape(comp),
    }
    ret = system "nice #{cmd}"
    return audio unless ret # return original file on failure

    comp
  end

end
