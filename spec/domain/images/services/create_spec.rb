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

    subject(:result) { described_class.new({ thought: thought, file: file_params }).call }

    shared_examples 'processing is failed' do
      it { expect { subject }.not_to(change { Image.count }) }
      it { expect(result[:errors]).to eq errors }
      it { expect(result[:entity]).to eq nil }
      it 'does not publish kafka event' do
        expect_any_instance_of(WaterDrop::Producer).not_to receive(:produce_sync)
      end
      it 'does not create image' do
        expect_any_instance_of(Images::Services::Create).not_to receive(:call)
      end
    end

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
      let(:errors) { ['maybe some validation can fail'] }
      let(:created_image_mock) { FactoryBot.create(:image) }

      before do
        allow(Image).to receive(:create).and_return(created_image_mock)
        allow(created_image_mock).to receive_message_chain(:errors, :any?).and_return(true)
        allow(created_image_mock).to receive_message_chain(:errors, :full_messages).and_return(errors)
      end

      it_behaves_like 'processing is failed'
    end

    context 'when file processing fails' do
      let(:error) { 'Dramatic error description' }
      let(:errors) { [error] }

      before do
        allow_any_instance_of(Tempfile).to receive(:write).and_raise(error)
      end

      it_behaves_like 'processing is failed'
    end
  end
end
