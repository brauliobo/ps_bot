require 'bundler/setup'
require 'active_support/all'
require 'hashie'

require 'telegram/bot'
require 'mechanize'

require_relative 'exts/sym_mash'
require_relative 'exts/peach'
require_relative 'scraper'
require_relative 'bot'

bot = Bot.new ENV['TOKEN']

if ps_number = ARGV[0]

  if ps_number == 'all'
    (1..5018).peach do |n|
      scraper = Scraper.new
      scraper.fetch n
    rescue => e
      STDERR.puts "PS#{n} failed: #{e.message}: #{e.backtrace.join "\n"}"
    end
  else
    ps = scraper.fetch ps_number
    puts bot.caption ps
  end

  exit
end

bot.start
