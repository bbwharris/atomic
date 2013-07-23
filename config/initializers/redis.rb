unless Rails.env.development?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Redis.current = Redis.new(host: uri.host, port: uri.port, password: url.password)
end
