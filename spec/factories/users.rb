# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    uid          { Faker::Number.number(digits: 7).to_s }
    store_hash   { Faker::Alphanumeric.alpha(number: 10) }
    username     { Faker::Internet.email }
    email        { Faker::Internet.email }
    access_token { Faker::Internet.password(min_length: 32, max_length: 40) }
    scope        { Faker::Lorem }
    created_at   { Faker::Time.backward(days: 14, period: :evening) }
    updated_at   { Faker::Time.backward(days: 7, period: :morning) }

    factory :invalid_user do
      email      { nil }
      store_hash { nil }
    end
  end
end
