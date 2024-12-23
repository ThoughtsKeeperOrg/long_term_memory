# frozen_string_literal: true

FactoryBot.define do
  factory :thought do
    content { FFaker::Lorem.paragraph }
  end
end
