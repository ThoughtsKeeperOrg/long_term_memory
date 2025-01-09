# frozen_string_literal: true

module Types
  class AssociationsType < Types::BaseObject
    field :thoughts, [ThoughtType]
  end
end
