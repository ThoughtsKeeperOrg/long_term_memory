# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Images::Services::Create, type: :service_object do
  describe '#call' do
    let(:thought) { FactoryBot.create :thought }
    let(:filename) { 'img.jpg' }
    let(:type) { 'image/jpeg' }
    let(:convert_to_text) { false }
    let(:file_base64) { Base64.encode64(File.open('spec/fixtures/img.jpg', 'rb').read) }
    let(:file_params) do
      {
        type: type,
        filename: filename,
        file_base64: file_base64,
        convert_to_text: convert_to_text
      }
    end

    subject { described_class.new({ thought: thought, file: file_params }).call }

    context 'when entity is created' do
      it { expect { subject }.to change { Image.count }.by(1) }

      it 'creates an Image object' do
        expect(subject[:entity]).to be_a(Image)
        expect(subject[:entity].thought).to eq thought
        expect(subject[:entity].file).to be_a ActiveStorage::Attached::One
      end

      it 'stores given file' do
        expect(Base64).to receive(:decode64).with(file_base64).and_call_original

        subject

        expect(subject[:entity].file.filename).to eq filename
      end

      it 'does not publish event to kafka' do
        expect(Karafka).not_to receive(:producer)
        expect { subject }.not_to(change { karafka.produced_messages.size })
      end

      context 'when convert_to_text is true' do
        let(:convert_to_text) { true }

        it { expect { subject }.to change { karafka.produced_messages.size }.by(1) }

        it 'publishes event to kafka' do
          event_payload = { file_path: subject[:entity].path, filename: subject[:entity].file.filename }.to_json
          expect(karafka.produced_messages.first[:key]).to eq(subject[:entity].id.to_s)
          expect(karafka.produced_messages.first[:topic]).to eq('textimage_created')
          expect(karafka.produced_messages.first[:payload]).to eq(event_payload)
        end
      end
    end

    context 'when entity is not created' do
      # TODO
    end
  end
end
