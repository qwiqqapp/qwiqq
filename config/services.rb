if Rails.env.test?
  ENV["INDEXTANK_API_URL"] = "http://127.0.0.1"
else 
  # s3
  ENV["S3_KEY"] = "AKIAJOMG7WLZJME47VDQ"
  ENV["S3_SECRET"] = "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"
  ENV["S3_BUCKET"] = "qwiqq.images.#{Rails.env}"
  
  # twitter keys
  ENV["TWITTER_CONSUMER_KEY"] = "MYYVJCNWkUjA1sHlNQUHcA"
  ENV["TWITTER_CONSUMER_SECRET"] = "a2u0U4YtL37Sa8Gzpvubd4RhpMI6BBzMmarS1t8VsU"

  # twilio keys
  ENV["TWILIO_SID"] = "AC8a91db9d42184183a216192d91e13a3e"
  ENV["TWILIO_AUTH_TOKEN"] = "ad9648ce4c1e5d0d700cbab0b3cda845"
  ENV["TWILIO_FROM_NUMBER"] = "(512) 948-3477" # this number must be verified with twilio

  # postmarkapp
  ENV["POSTMARK_API_KEY"] = "a961c397-264d-47e5-aa2a-146c2aac575e"
end
