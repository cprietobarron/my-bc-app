# frozen_string_literal: true

FactoryBot.define do
  factory :sync_record do
    channel

    sync_mode     { 1 }
    progress      { Faker::Alphanumeric.alpha(number: 10) }
    progress_text { Faker::Alphanumeric.alpha(number: 10) }
    job_id        { Faker::Alphanumeric.alpha(number: 10) }
    change_count  { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
    stats         { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
    created_at    { Faker::Time.backward(days: 14, period: :evening) }
    updated_at    { Faker::Time.backward(days: 7, period: :morning) }
  end
end
