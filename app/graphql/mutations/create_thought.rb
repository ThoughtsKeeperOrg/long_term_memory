# frozen_string_literal: true

module Mutations
  class CreateThought < Mutations::BaseMutation
    field :entity, Types::ThoughtType
    field :errors, [String], null: false

    argument :content, String, required: true
    argument :file, [Types::FileType, null: true], required: false

    def resolve(content:, file: nil)
      thought_params = {
        thought: { content: content }
      }

      Thoughts::Services::Create.new(thought_params).call
    end
  end
end
