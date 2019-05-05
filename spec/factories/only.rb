# frozen_string_literal: true

FactoryBot.define do
  factory :only do
    _generic
    trait(:all_nil) { _all_nil }
  end
end
