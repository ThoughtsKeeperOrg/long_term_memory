require 'rails_helper'

RSpec.describe "Api::Thoughts", type: :request do
  let(:parsed_body) { JSON.parse(response.body) }

  describe 'GET /index' do
    let!(:thoughts) { FactoryBot.create_list(:thought, 2) }

    subject! { get('/api/thoughts') }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to eq thoughts.to_json }
  end

  describe 'GET /create' do
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
        expect(parsed_body['id']).to be_a Integer
        expect(parsed_body['content']).to eq content
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
        let(:created_thought) { Thought.find(parsed_body['id']) }

        it_behaves_like 'entity is created'

        it { expect { subject }.to change { Image.count }.by(1) }

        it 'stores file' do
          expect(Base64).to receive(:decode64).with(file_base64).and_call_original

          subject

          expect(created_thought.image.file.filename).to eq filename
        end

        it 'does not publish event to kafka' do
          expect(Karafka).not_to receive(:producer)

          subject
        end

        it { expect { subject }.not_to change { karafka.produced_messages.size } }

        context 'when convert_to_text is true' do
          let(:convert_to_text) { true }
          let(:event_payload) do
            { file_path: created_thought.image.path, filename: created_thought.image.file.filename }.to_json
          end

          it { expect { subject }.to change { karafka.produced_messages.size }.by(1) }

          it 'publishes event to kafka' do
            subject
            expect(karafka.produced_messages.first[:key]).to eq(created_thought.image.id.to_s)
            expect(karafka.produced_messages.first[:topic]).to eq('text_image.created')
            expect(karafka.produced_messages.first[:payload]).to eq(event_payload)
          end
        end
      end
    end
  end
end
