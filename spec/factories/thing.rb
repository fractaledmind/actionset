# frozen_string_literal: true

FactoryBot.define do
  factory :thing do
    generic

    association :only
    transient do
      alots_count { 3 }
    end
    after(:create) do |thing, evaluator|
      create_list(:alot, evaluator.alots_count, thing: thing)
    end
  end
end
