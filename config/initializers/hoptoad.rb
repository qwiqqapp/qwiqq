# production: 390aeca598c8e84e439e67a4034dcdd2
# staging: 0ff186f437e676f2c6f7047f854b527b

HoptoadNotifier.configure do |config|
  config.api_key = ENV["HOPTOAD_API_KEY"]
end
