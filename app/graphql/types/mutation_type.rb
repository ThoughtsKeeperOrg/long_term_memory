# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_thought, mutation: Mutations::CreateThought
  end
end
