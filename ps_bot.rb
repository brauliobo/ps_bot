require 'bundler/setup'
require 'active_support/all'
require 'hashie'
require 'premailer'

require 'telegram/bot'
require 'mechanize'

require_relative 'sym_mash'
require_relative 'scraper'
require_relative 'bot'

class PSBot
end

if ps_number = ARGV[0]
  scraper = Scraper.new
  pp scraper.fetch ps_number
  exit
end

Bot.new(ENV['TOKEN']).start
