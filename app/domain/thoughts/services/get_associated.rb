# frozen_string_literal: true

module Thoughts
  module Services
    class GetAssociated
      attr_accessor :params

      def call(entity_id)
        ids = similarity_esitimations(entity_id).map { |item| item[:id] }

        return result unless ids.any?

        result[:items] = Thought.where(id: ids)
                                .all

        result
      end

      private

      def result
        @result ||= { errors: [], items: [] }
      end

      def similarity_esitimations(entity_id)
        @similarity_esitimations ||= Thoughts::Queries::SimilarityEsitimations.new.call(entity_id)
      end
    end
  end
end
