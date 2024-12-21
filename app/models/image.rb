class Image < ApplicationRecord
  belongs_to :thought

  has_one_attached :file

  def path
    ActiveStorage::Blob.service.path_for(file.key)
  end
end
