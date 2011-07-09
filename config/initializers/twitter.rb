module Qwiqq
  def self.twitter_consumer_key
    twitter_config["consumer_key"]
  end

  def self.twitter_consumer_secret
    twitter_config["consumer_secret"]
  end

  private
    def self.twitter_config
      YAML.load_file(Rails.root.join("config", "twitter.yml"))[Rails.env]
    end
end