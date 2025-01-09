module Resolvers
  class AssociationsResolver < BaseResolver
    type Types::AssociationsType, null: false
    argument :id, String, required: true 

    def resolve(id:)
      {thoughts: ::Thoughts::Services::GetAssociated.new.call(id)[:items]}
    end
  end
end