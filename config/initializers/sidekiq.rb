unless ENV["SECRET_KEY_BASE_DUMMY"]
  redis_url = ENV.fetch("REDIS_URL") do
    Rails.env.production? ? raise(KeyError, "REDIS_URL is required in production") : "redis://redis:6379/0"
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end