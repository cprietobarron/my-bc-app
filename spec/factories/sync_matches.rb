# frozen_string_literal: true

FactoryBot.define do
  factory :sync_match do
    channel

    categories { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
    products { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
    variants { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
    inventory { Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name", value: "Name.last_name" }) }
  end
end
