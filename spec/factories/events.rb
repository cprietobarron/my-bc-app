# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    channel
    event_type { Faker::Number.between(from: 1, to: 4) }
    data do
      JSON.parse(Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }))
    end
    has_error { Faker::Boolean.boolean }
    summary { Faker::String.random(length: 4) }
    created_at { Faker::Time.backward(days: 14, period: :evening) }
    updated_at { Faker::Time.backward(days: 7, period: :morning) }

    factory :invalid_event do
      event_type { nil }
      summary { nil }
    end

    factory :order_data do
      data { JSON.parse({ orders: { created: 1, updated: 2 } }.to_json) }
    end
  end
end
