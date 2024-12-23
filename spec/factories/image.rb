# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    thought
    file { Rack::Test::UploadedFile.new('spec/fixtures/img.jpg', 'image/jpeg') }
  end
end
