# frozen_string_literal: true

FactoryBot.define do
  factory :alot do
    sequence(:binary) { |n| Base64.encode64 [Faker::Crypto.sha256, n].join('-') }
    sequence(:boolean, &:even?)
    sequence(:date)     { |n| Faker::Date.between(n.send(:year).ago, n.send(:year).from_now).to_date }
    sequence(:datetime) { |n| Faker::Date.between(n.send(:year).ago, n.send(:year).from_now).to_datetime }
    sequence(:decimal)  { |n| Faker::Number.decimal(2).to_f + n }
    sequence(:float)    { |n| Faker::Number.decimal(2).to_f + n }
    sequence(:integer, &:to_i)
    sequence(:string) do |n|
      n.hash.abs.to_s.split('').map { |i| ('a'..'z').to_a.shuffle[i.to_i] }.join
    end
    sequence(:text)     { |n| [Faker::Lorem.paragraph, n].join('-') }
    sequence(:time)     { |n| Faker::Time.between(n.send(:year).ago, n.send(:year).from_now).to_s[12..-1] }
  end
end
