# frozen_string_literal: true

module Thoughts
  module Services
    class GetAssociated
      def initialize(params)
        @params = params
      end

      attr_accessor :params

      def call
        # driver.session do |session|
        #   query_result = session.run("MATCH (a:Thought { entity_id: $entity_id })-[similarity:similarity]-(node)
        #                         WHERE similarity.estimation > 0.0
        #                         RETURN node.entity_id as id, similarity.estimation as similarity
        #                         ORDER BY similarity.estimation DESC", entity_id: params[:entity_id].to_s)

        #   result[:items] = query_result.map(&:to_h)
        # end

        # result
      end

      private

      def result
        @result ||= { errors: [], items: [] }
      end

      def similarity_esitimations
        @similarity_esitimations ||= Thoughts::Services::GetAssociated.new.call(8)
      end
    end
  end
end
