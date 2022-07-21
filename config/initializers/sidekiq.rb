# frozen_string_literal: true

log_level = ENV.fetch("LOG_LEVEL", Logger::INFO)

Sidekiq.configure_client do |config|
  config.logger.level = log_level
end

Sidekiq.configure_server do |config|
  config.logger.level = log_level

  config.death_handlers << ->(job, ex) do
    Rails.logger.error "Uh oh, #{job["class"]} #{job["jid"]} just died with error #{ex.message}."
  end
end
