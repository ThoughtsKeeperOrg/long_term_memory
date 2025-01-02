# frozen_string_literal: true

module Thoughts
  module Services
    class GetAssociated
      def initialize(params)
        @params = params
      end

      attr_accessor :params

      def call
        driver.session do |session|
          query_result = session.run("MATCH (a:Thought { entity_id: $entity_id })-[similarity:similarity]-(node)
                                RETURN node.entity_id as id, similarity.estimation as similarity
                                ORDER BY similarity.estimation DESC", entity_id: params[:entity_id].to_s)

          result[:items] = query_result.map(&:to_h)
        end

        result
      end

      private

      def result
        @result ||= { errors: [], items: [] }
      end

      def driver
        url = URI::Generic.build(scheme: 'neo4j',
                                 host: ENV.fetch('NEO4J_HOST', 'localhost'),
                                 port: ENV.fetch('NEO4J_HOST', '7687')).to_s
        auth_tokens = Neo4j::Driver::AuthTokens.basic(ENV.fetch('NEO4J_USER', 'neo4j'),
                                                      ENV.fetch('NEO4J_PASSWORD', 'your_password'))
        Neo4j::Driver::GraphDatabase.driver(url, auth_tokens)
      end
    end
  end
end
