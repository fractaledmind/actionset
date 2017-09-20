# frozen_string_literal: true

FactoryGirl.define do
  sequence :string do |n|
    [Faker::RickAndMorty.character, n].join('-')
  end
  sequence :text do |n|
    [Faker::RickAndMorty.quote, n].join('-')
  end

  factory :foo do
    binary        { Base64.encode64 Faker::Crypto.sha256 }
    boolean       { [true, false].sample }
    date          { Faker::Date.between(1.year.ago, 1.year.from_now).to_date }
    datetime      { Faker::Time.between(1.year.ago, 1.year.from_now).to_datetime }
    decimal       { Faker::Number.decimal(2).to_f }
    float         { Faker::Number.decimal(2).to_f }
    integer       { Faker::Number.between(1, 100) }
    string        { generate(:string) }
    text          { generate(:text) }
    time          { Faker::Time.between(1.year.ago, 1.year.from_now).to_s[12..-1] }

    association :assoc
  end
end
