# frozen_string_literal: true

Rails.application.configure do
  # BigCommerce Market App
  config.x.market_app.tap do |m|
    m.id            = ENV["BC_APP_ID"].to_i
    m.client_id     = ENV["BC_APP_CLIENT_ID"]
    m.client_secret = ENV["BC_APP_CLIENT_SECRET"]
  end

  # App
  config.app_url      = ENV["APP_HOST"]
  config.frontend_url = ENV["FRONTEND_APP_HOST"]
  config.sentry_dsn   = ENV["SENTRY_DSN"]

  # CORS
  config.cors_allowed_origins = ENV["CORS_ALLOWED_ORIGINS"]

  # Admin credentials
  config.x.admin.tap do |s|
    s.username = ENV["ADMIN_USERNAME"]
    s.password = ENV["ADMIN_PASSWORD"]
  end

  # Api V1 Web
  config.x.api.tap do |s|
    s.username = ENV["API_USERNAME"]
    s.password = ENV["API_PASSWORD"]
  end

  if Rails.env.development?
    config.x.dev_user.tap do |user|
      user.email      = ENV["DEV_EMAIL"]
      user.store_hash = ENV["DEV_STORE_HASH"]
      user.token      = ENV["DEV_API_TOKEN"]
    end
  end
end
