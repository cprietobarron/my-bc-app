# frozen_string_literal: true

require "flipper/ui"
require "flipper/adapters/redis"

Flipper::UI.configure do |config|
  config.banner_text = Rails.env.upcase
  config.banner_class = case Rails.env
                        when "production" then "danger"
                        when "development" then "success"
                        else
                          "warning"
                        end
end

Rails.application.configure do
  flags = config_for(:feature_flags)
  flags&.each_key do |feature_name|
    Flipper.add(feature_name)
  end
end
