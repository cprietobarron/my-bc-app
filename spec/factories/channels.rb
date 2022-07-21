# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    user

    additional_info { Faker::Json.shallow_json(width: 3) }
    counts { Faker::Json.shallow_json(width: 3) }
    refresh_token { Faker::Internet.password(min_length: 32, max_length: 40) }
    settings { { "sync_direction" => "import" } }
    access_token { Faker::Internet.password(min_length: 32, max_length: 40) }
    token_expires_at { Faker::Date.forward(days: 1) }
    created_at { Faker::Date.forward(days: 23) }
    updated_at { Faker::Date.forward(days: 1) }
    provider { "clover" }
    status { 0 }

    factory :invalid_channel do
      access_token { nil }
      refresh_token { nil }
    end
  end
end
