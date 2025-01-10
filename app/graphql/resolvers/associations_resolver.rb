# frozen_string_literal: true

module Resolvers
  class AssociationsResolver < BaseResolver
    type [Types::ThoughtType], null: false
    argument :id, String, required: true

    def resolve(id:)
      ::Thoughts::Services::GetAssociated.new.call(id)[:items]
    end
  end
end
