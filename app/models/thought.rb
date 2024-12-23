# frozen_string_literal: true

class Thought < ApplicationRecord
  has_one :image, dependent: :destroy
end
