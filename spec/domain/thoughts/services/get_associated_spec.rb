# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Thoughts::Services::GetAssociated, type: :query_object do
  describe '#call' do
    let(:thought) { FactoryBot.create(:thought) }
    let(:graph_result_mock) { [] }

    subject(:result) { described_class.new.call(thought.id) }

    before do
      allow_any_instance_of(Thoughts::Queries::SimilarityEsitimations).to receive(:call)
                                                                      .and_return(graph_result_mock)
    end

    it 'makes query to graph db' do
      expect(Thoughts::Queries::SimilarityEsitimations).to receive(:new).and_call_original
      expect_any_instance_of(Thoughts::Queries::SimilarityEsitimations).to receive(:call)
                                                                       .with(thought.id)
      subject
    end

    context 'when entity has no relations in graph' do
      it { expect(result[:items]).to eq([]) }
    end

    context 'when entity has relations in graph' do
      let(:thought2) { FactoryBot.create(:thought) }
      let(:thought3) { FactoryBot.create(:thought) }
      let(:graph_result_mock) do
        [
          { id: thought3.id, similarity: 0.9 },
          { id: thought2.id, similarity: 0.3 }
        ]
      end

      it 'returns only similar items' do
        expect(result[:items].count).to eq(2)
      end

      it 'returns only similar items' do
        expect(result[:items]).to all(be_a(Thought))
      end

      it 'returns items in order by similarity' do
        expect(result[:items][0][:id]).to eq(thought3.id)
        expect(result[:items][1][:id]).to eq(thought2.id)
      end
    end
  end
end
