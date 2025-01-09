# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LongTermMemorySchema, type: :graphql_schema do
  subject(:result) { LongTermMemorySchema.execute(query_string) }

  describe 'Thought query' do
    let(:thought) { FactoryBot.create(:thought) }
    let(:query_string) do
      "{
        thought(id: #{thought.id}) {
          id
          content
        }
      }"
    end

    it 'returns thought object' do
      expect(result['data']['thought']['id']).to eq(thought.id.to_s)
      expect(result['data']['thought']['content']).to eq(thought.content)
    end
  end

  describe 'Associations query' do
    let(:thought) { FactoryBot.create(:thought) }
    let!(:associated_thoughts) { [] }

    let(:query_string) do
      "{
        associations(id: \"#{thought.id}\") {
          
            id
            content
        }
      }"
    end

    before do
      service_result = { errors: [], items: associated_thoughts }
      allow_any_instance_of(Thoughts::Services::GetAssociated).to receive(:call)
                                                              .with(thought.id.to_s)
        .and_return(service_result)
    end

    context 'thought has no associations' do
      it 'returns empty array' do
        expect(result['data']['associations']).to eq []
      end
    end

    context 'thought has some associations' do
      let!(:associated_thoughts) { FactoryBot.create_list(:thought, 2) }

      it 'returns associated thoughts' do
        expect(result['data']['associations'].count).to eq 2
      end
    end
  end
end
