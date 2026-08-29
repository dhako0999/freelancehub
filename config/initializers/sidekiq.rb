
unless ENV["SECRET_KEY_BASE_DUMMY"]
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URL") }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL") }
  end
end