FactoryBot.define do
  factory :thought do
    content { FFaker::Lorem.paragraph }
  end
end
