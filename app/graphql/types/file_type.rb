# frozen_string_literal: true

module Types
  class FileType < Types::BaseInputObject
    argument :filename, String
    argument :type, String
    argument :file_base64, String
    argument :convert_to_text, Boolean
  end
end
