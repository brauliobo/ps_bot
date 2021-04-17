require 'shellwords'
require_relative 'cache'

class Mediazip

  class_attribute :opus_command
  self.opus_command = <<-EOC
    ffmpeg -loglevel quiet -i %{input} -f wav - |
    opusenc --bitrate 64 --quiet - %{output}
  EOC

  class_attribute :m4a_command
  self.m4a_command = <<-EOC
    ffmpeg -loglevel quiet -i %{input} -f wav - |
    ffmpeg -i - -b:a 80k -loglevel quiet %{output}
  EOC

  def self.m4a audio
    run :m4a, audio
  end

  def self.opus audio
    run :opus, audio
  end

  protected

  def self.run ext, audio
    comp = compressed_path audio, ext
    return comp if Cache.present? comp

    cmd  = send(:"#{ext}_command") % {
      input:  Shellwords.escape(audio),
      output: Shellwords.escape(comp),
    }
    ret = system "nice #{cmd}"
    return audio unless ret # return original file on failure

    comp
  end

  def self.compressed_path audio, ext
    comp = File.basename audio.sub(/.[^\.]+$/, ".#{ext}")
    comp = "#{Cache.audios_compressed_path}/#{comp}"
    comp
  end

end
