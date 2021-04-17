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

scraper = Scraper.new
if ps_number = ARGV[0]
  pp scraper.fetch ps_number
  exit
end

Bot.new(ENV['TOKEN']).start
