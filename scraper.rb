require_relative 'sarkarverse'
require_relative 'ps_net'

class Scraper

  def initialize
    @sarkarverse = Sarkarverse.new
    @ps_net      = PSNet.new
  end

  def fetch number
    scraper = if @sarkarverse.exists? number then @sarkarverse else @ps_net end
    scraper.fetch number
  end

end
