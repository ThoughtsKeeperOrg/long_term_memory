class Image < ApplicationRecord
  belongs_to :thought

  has_one_attached :file
end
