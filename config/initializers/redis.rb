#needed by heroku
if Rails.env.production?
  begin
    uri = URI.parse(ENV["REDISTOGO_URL"])
    Redis.current = Redis.new(host: uri.host, port: uri.port, password: uri.password)
  rescue nil
  end
end
