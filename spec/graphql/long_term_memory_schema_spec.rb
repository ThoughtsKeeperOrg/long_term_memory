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

  describe 'Thought create mutation query' do
    let(:query_string) do
      "mutation createThought{
        createThought(input: {content: \"test\"}){
            entity{
              id
              content
            }
          }
        }
      }"
    end

    it 'returns thought object' do
      expect(result['data']['createThought']['entity']['id']).to be_present
      expect(result['data']['createThought']['entity']['content']).to eq('test')
    end

    context 'file parameter is set' do
      let(:content) { 'test' }
      let(:filename) { 'img.jpg' }
      let(:type) { 'image/jpeg' }
      let(:convert_to_text) { true }
      let(:file_base64) { 'file_base64_str' }
      let(:params) do
        {
          thought: { content: content },
          file: {
            type: type,
            filename: filename,
            file_base64: file_base64,
            convert_to_text: convert_to_text
          }
        }
      end

      let(:query_string) do
        "mutation createThought{
          createThought( input: { content: \"#{content}\",
                                  file: { filename: \"#{filename}\",
                                  type: \"#{type}\",
                                  fileBase64: \"#{file_base64}\",
                                  convertToText: true}}){
              entity{
                id
                content
              }
            }
          }
        }"
      end

      it 'calls service to store the data' do
        expect(Thoughts::Services::Create).to receive(:new).with(params).and_call_original
        expect_any_instance_of(Thoughts::Services::Create).to receive(:call)
        subject
      end
    end
  end
end
