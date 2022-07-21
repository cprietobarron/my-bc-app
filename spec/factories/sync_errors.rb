# frozen_string_literal: true

FactoryBot.define do
  factory :sync_error do
    sync_record

    error { Faker::Alphanumeric.alpha(number: 10) }
    item  { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
  end
end
