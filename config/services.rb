if Rails.env.test?
  ENV["INDEXTANK_API_URL"] = "http://127.0.0.1"
else 
  # s3
  ENV["S3_KEY"] = "AKIAJOMG7WLZJME47VDQ"
  ENV["S3_SECRET"] = "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"
  ENV["S3_BUCKET"] = "qwiqq.images.#{Rails.env}"

  # indextank
  ENV["INDEXTANK_API_URL"] = "http://:ugsrn4tHabBmh+@dhqws.api.indextank.com"
  ENV["INDEXTANK_INDEX"] = "#{Rails.env}_deals"

  # twitter keys
  ENV["TWITTER_CONSUMER_KEY"] = "MYYVJCNWkUjA1sHlNQUHcA"
  ENV["TWITTER_CONSUMER_SECRET"] = "a2u0U4YtL37Sa8Gzpvubd4RhpMI6BBzMmarS1t8VsU"

  # postmarkapp
  ENV["POSTMARK_API_KEY"] = "a961c397-264d-47e5-aa2a-146c2aac575e"
end
