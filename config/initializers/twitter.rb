module Qwiqq
  def self.twitter_consumer_key
    ENV["TWITTER_CONSUMER_KEY"]
  end

  def self.twitter_consumer_secret
    ENV["TWITTER_CONSUMER_SECRET"]
  end
end