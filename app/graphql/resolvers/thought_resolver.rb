# frozen_string_literal: true

module Resolvers
  class ThoughtResolver < BaseResolver
    type Types::ThoughtType, null: false
    argument :id, ID

    def resolve(id:)
      ::Thought.find(id)
    end
  end
end
