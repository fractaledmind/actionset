# frozen_string_literal: true

def fit_to_minmax(number, max:, min: 1)
  max_diff = max * number.div(max)
  fitted = number - max_diff

  return fitted if fitted >= min

  fit_to_minmax(fitted + 1, max: max, min: min)
end

FactoryBot.define do
  trait :_generic do
    sequence(:binary) { |n| Base64.encode64 [Faker::Crypto.sha256, n].join('-') }
    sequence(:boolean, &:even?)
    sequence(:date) do |n|
      [
        "19#{fit_to_minmax(n, max: 99).to_s.rjust(2, '0')}",
        fit_to_minmax(n, max: 12).to_s.rjust(2, '0'),
        fit_to_minmax(n, max: 28).to_s.rjust(2, '0')
      ].join('-')
    end
    sequence(:datetime) do |n|
      "#{date}T#{time}:#{fit_to_minmax(n, max: 60).to_s.rjust(2, '0')}+00:00"
    end
    sequence(:decimal)  { |n| (n.to_s + '.' + Faker::Number.number(2)).to_f }
    sequence(:float)    { |n| (n.to_s + '.' + Faker::Number.number(2)).to_f }
    sequence(:integer, &:to_i)
    sequence(:string) do |n|
      n.hash.abs.to_s.split('').map { |i| ('a'..'z').to_a.shuffle[i.to_i] }.join
    end
    sequence(:text) { |n| [Faker::Lorem.paragraph, n].join('-') }
    sequence(:time) do |n|
      [
        fit_to_minmax(n, max: 12).to_s.rjust(2, '0'),
        rand(60).to_s.rjust(2, '0')
      ].join(':')
    end
  end

  trait :_all_nil do
    binary    { nil }
    boolean   { nil }
    date      { nil }
    datetime  { nil }
    decimal   { nil }
    float     { nil }
    integer   { nil }
    string    { nil }
    text      { nil }
    time      { nil }
  end
end
