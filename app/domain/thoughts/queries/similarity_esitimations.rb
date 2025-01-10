# frozen_string_literal: true

module Thoughts
  module Queries
    class SimilarityEsitimations
      CYPHER_QUERY = "MATCH (a:Thought { entity_id: $entity_id })-[similarity:similarity]-(node)
                      WHERE similarity.estimation > 0.0
                      RETURN node.entity_id as id, similarity.estimation as similarity
                      ORDER BY similarity.estimation DESC"

      def call(entity_id)
        items = []
        db_client.session do |session|
          query_result = session.run(CYPHER_QUERY, entity_id: entity_id.to_s)

          items = query_result.map(&:to_h)
        end

        items
      end

      private

      def db_client
        Neo4jClient.new
      end
    end
  end
end
