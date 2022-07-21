# frozen_string_literal: true

FactoryBot.define do
  factory :sync_operation do
    name          { Faker::Name.name }
    item_type     { "product" }
    error_message { Faker::String.random(length: 6) }
    provider      { "clover" }
    step          { "push" }
    data          do
      Faker::Json.shallow_json(width: 3, options: { key: "Name.first_name",
                                                    value: "Name.last_name" })
    end
    action        { "new" }
    original_type { "item" }
  end
end
