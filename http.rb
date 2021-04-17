class Http

  def initialize
    @mechanize = Mechanize.new
  end

  def get url
    @mechanize.get url
  end

  def method_missing method, *args, &block
    @mechanize.send method, *args, &block
  end

end
