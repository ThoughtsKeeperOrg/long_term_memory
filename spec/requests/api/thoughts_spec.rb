require 'rails_helper'

RSpec.describe "Api::Thoughts", type: :request do
  let(:parsed_body) { JSON.parse(response.body) }

  describe 'GET /index' do
    let!(:thoughts) { FactoryBot.create_list(:thought, 2) }

    subject! { get('/api/thoughts') }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to eq thoughts.to_json }
  end

  describe 'POST /create' do
    let(:content) { 'some text' }
    let(:file) { nil }
    let(:entity_params) { { thought: { content: content }, file: file } }

    subject { post('/api/thoughts', params: entity_params) }

    shared_examples 'entity is created' do
      it 'responds with 201 status' do
        subject
        expect(response.status).to eq 201
      end

      it 'returns created object' do
        subject
        expect(parsed_body['entity']['id']).to be_a Integer
        expect(parsed_body['entity']['content']).to eq content
      end

      it 'calls service object' do
        expect_any_instance_of(Thoughts::Services::Create).to receive(:call).and_call_original

        subject
      end

      it { expect { subject }.to change { Thought.count }.by(1) }
    end

    context 'when entity is created' do
      it_behaves_like 'entity is created'

      context 'when file is submited' do
        let(:filename) { 'img.jpg' }
        let(:type) { 'image/jpeg' }
        let(:convert_to_text) { false }
        let(:file_base64) { Base64.encode64(File.open('spec/fixtures/img.jpg', 'rb').read) }
        let(:file) do
          {
            type: type,
            filename: filename,
            file_base64: file_base64,
            convert_to_text: convert_to_text
          }
        end

        it_behaves_like 'entity is created'
      end
    end

    context 'when creation failed' do
      let(:errors) { [ "error description 1", "error description 2" ] }

      before do
        allow_any_instance_of(Thoughts::Services::Create).to receive(:call).and_return({ errors: errors })
      end

      it 'responds with 400 status' do
        subject
        expect(response.status).to eq 400
      end

      it 'returns errors' do
        subject
        expect(parsed_body['errors']).to eq errors
      end
    end
  end
end
