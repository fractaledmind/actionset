# frozen_string_literal: true

FactoryBot.define do
  factory :foo do
    sequence(:binary) { |n| Base64.encode64 [Faker::Crypto.sha256, n].join('-') }
    sequence(:boolean, &:even?)
    sequence(:date)     { |n| Faker::Date.between(n.send(:year).ago, n.send(:year).from_now).to_date }
    sequence(:datetime) { |n| Faker::Date.between(n.send(:year).ago, n.send(:year).from_now).to_datetime }
    sequence(:decimal)  { |n| Faker::Number.decimal(2).to_f + n }
    sequence(:float)    { |n| Faker::Number.decimal(2).to_f + n }
    sequence(:integer, &:to_i)
    sequence(:string)   { |n| [Faker::RickAndMorty.character, n].join('-') }
    sequence(:text)     { |n| [Faker::RickAndMorty.quote[0..50], n].join('-') }
    sequence(:time)     { |n| Faker::Time.between(n.send(:year).ago, n.send(:year).from_now).to_s[12..-1] }

    association :assoc
  end
end
