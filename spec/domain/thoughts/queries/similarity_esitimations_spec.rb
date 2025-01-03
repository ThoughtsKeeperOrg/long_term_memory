# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Thoughts::Queries::SimilarityEsitimations, type: :query_object, neo4j: true do
  describe '#call' do
    let(:thought) { FactoryBot.create(:thought) }

    subject(:result_items) { described_class.new.call(thought.id) }

    context 'when entity has no relations in graph' do
      it { is_expected.to eq([]) }
    end

    context 'when entity has relations in graph' do
      let(:thought2) { FactoryBot.create(:thought) }
      let(:thought3) { FactoryBot.create(:thought) }
      let(:thought4) { FactoryBot.create(:thought) }

      before do
        db_client = Neo4jClient.new

        db_client.session do |session|
          session.run('CREATE (t:Thought { entity_id: $entity_id })', entity_id: thought.id.to_s)
          session.run('CREATE (t:Thought { entity_id: $entity_id })', entity_id: thought2.id.to_s)
          session.run('CREATE (t:Thought { entity_id: $entity_id })', entity_id: thought3.id.to_s)
          session.run('CREATE (t:Thought { entity_id: $entity_id })', entity_id: thought4.id.to_s)
          session.run("MATCH (a:Thought { entity_id: $a_entity_id })
                       MATCH (b:Thought { entity_id: $b_entity_id })
                       CREATE (a)-[r:similarity {estimation: $similarity}]->(b)", a_entity_id: thought.id.to_s,
                                                                                  b_entity_id: thought2.id.to_s,
                                                                                  similarity: 0.3)
          session.run("MATCH (a:Thought { entity_id: $a_entity_id })
                       MATCH (b:Thought { entity_id: $b_entity_id })
                       CREATE (a)-[r:similarity {estimation: $similarity}]->(b)", a_entity_id: thought.id.to_s,
                                                                                  b_entity_id: thought3.id.to_s,
                                                                                  similarity: 0.9)
          session.run("MATCH (a:Thought { entity_id: $a_entity_id })
                       MATCH (b:Thought { entity_id: $b_entity_id })
                       CREATE (a)-[r:similarity {estimation: $similarity}]->(b)", a_entity_id: thought.id.to_s,
                                                                                  b_entity_id: thought3.id.to_s,
                                                                                  similarity: 0.0)
        end
      end

      after do
        db_client = Neo4jClient.new

        ids = [thought.id.to_s, thought2.id.to_s, thought3.id.to_s, thought4.id.to_s]
        db_client.session do |session|
          session.run('MATCH (n) WHERE n.entity_id IN $ids DETACH DELETE n', ids: ids)
        end
      end

      it 'returns only similar items' do
        expect(result_items.count).to eq(2)
      end

      it 'returns items in order by similarity' do
        expect(result_items[0][:id]).to eq(thought3.id.to_s)
        expect(result_items[1][:id]).to eq(thought2.id.to_s)
      end
    end
  end
end
