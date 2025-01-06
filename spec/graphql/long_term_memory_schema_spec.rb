# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LongTermMemorySchema, type: :graphql_schema do
  
  subject(:result) { LongTermMemorySchema.execute(query_string) }

  # let(:parsed_body) { JSON.parse(response.body) }



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
end
