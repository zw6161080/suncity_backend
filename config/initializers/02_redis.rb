redis_host = ENV.fetch('REDIS_HOST', '127.0.0.1')
redis_port = ENV.fetch('REDIS_PORT', '6379')

redis_conn = proc {
  Redis.new(:host => redis_host, :port => redis_port, :db => 15)
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)

  schedule_file = "config/sidekiq_schedule.yml"
  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
