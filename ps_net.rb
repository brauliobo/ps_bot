require_relative 'cached_http'

class PSNet

  class_attribute :cached_http
  self.cached_http = CachedHttp.new

end
