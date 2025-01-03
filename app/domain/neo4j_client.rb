# frozen_string_literal: true

class Neo4jClient
  def initialize
    url = URI::Generic.build(scheme: 'neo4j',
                             host: ENV.fetch('NEO4J_HOST', 'localhost'),
                             port: ENV.fetch('NEO4J_PORT', '7687')).to_s
    auth_tokens = Neo4j::Driver::AuthTokens.basic(ENV.fetch('NEO4J_USER', 'neo4j'),
                                                  ENV.fetch('NEO4J_PASSWORD', 'your_password'))
    @driver = Neo4j::Driver::GraphDatabase.driver(url, auth_tokens)
  end

  attr_reader :driver

  delegate :session, to: :driver
end
