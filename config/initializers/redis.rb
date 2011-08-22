# use the system redis client
redis = begin
  config_path = Rails.root.join("config", "redis.yml")
  config = File.exists?(config_path) ?
    (YAML.load_file(config_path)[Rails.env].symbolize_keys rescue {}) : {}
  Redis.new(config)
end

Qwiqq.redis = redis
Resque.redis = redis

