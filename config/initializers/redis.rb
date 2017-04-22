if Rails.env == "development"
	$redis = Redis.new(host: '192.168.1.3')
else
	uri = URI.parse(ENV['REDISTOGO_URL'])
	$redis = Redis.new(url: uri)
end