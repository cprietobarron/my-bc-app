# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bigcommerce,
           Rails.configuration.x.market_app.client_id,
           Rails.configuration.x.market_app.client_secret
end
