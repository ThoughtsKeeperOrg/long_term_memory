# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Thoughts::Services::Create, type: :service_object do
  describe '#call' do
    subject(:result) { described_class.new(params).call }

    let(:params) { { thought: { content: 'test' }, file: file_params } }
    let(:file_params) { nil }
    let(:created_thought_mock) { FactoryBot.create(:thought) }

    it { expect { subject }.to change { Thought.count }.by(1) }
    it { expect(result[:errors]).to eq [] }
    it { expect(result[:entity]).to be_a(Thought) }
    it { expect(result[:entity].content).to eq(params[:thought][:content]) }

    it 'publishes kafka event' do
      allow(Thought).to receive(:create).and_return(created_thought_mock)
      payload = { entitity_type: :thought,
                  entity: created_thought_mock,
                  status: :updated,
                  user_id: 'placeholder-user_id' }.to_json
      expect_any_instance_of(WaterDrop::Producer).to receive(:produce_sync)
                                                 .with(key: created_thought_mock.id.to_s,
                                                       topic: :entities_updates,
                                                       payload: payload)
      subject
    end

    context 'when thought creation has errors' do
      let(:errors) { ['maybe some validation can fail'] }

      before do
        allow(Thought).to receive(:create).and_return(created_thought_mock)
        allow(created_thought_mock).to receive_message_chain(:errors, :any?).and_return(true)
        allow(created_thought_mock).to receive_message_chain(:errors, :full_messages).and_return(errors)
      end

      it { expect { subject }.not_to(change { Thought.count }) }
      it { expect(result[:errors]).to eq errors }
      it { expect(result[:entity]).to eq nil }
      it 'does not publish kafka event' do
        expect_any_instance_of(WaterDrop::Producer).not_to receive(:produce_sync)
      end
      it 'does not create image' do
        expect_any_instance_of(Images::Services::Create).not_to receive(:call)
      end
    end

    context 'when file is given' do
      let(:filename) { 'img.jpg' }
      let(:type) { 'image/jpeg' }
      let(:convert_to_text) { false }
      let(:file_base64) { 'base_64_encoded_file_string' }
      let(:file_params) do
        {
          type: type,
          filename: filename,
          file_base64: file_base64,
          convert_to_text: convert_to_text
        }
      end
      let(:image_service_double) do
        instance_double('Images::Services::Create', call: { errors: file_processing_errors })
      end
      let(:file_processing_errors) { [] }

      it 'calls image create service' do
        expect(Images::Services::Create)
          .to receive(:new)
          .with({ thought: kind_of(Thought), file: file_params })
          .and_return(image_service_double)
        expect(image_service_double).to receive(:call)
        subject
      end

      it 'does not publish kafka event' do
        expect_any_instance_of(WaterDrop::Producer).not_to receive(:produce_sync)

        subject
      end

      context 'when image creation failed' do
        let(:file_processing_errors) { ['some error'] }

        before do
          allow(Images::Services::Create)
            .to receive(:new)
            .with({ thought: kind_of(Thought), file: file_params })
            .and_return(image_service_double)
        end

        it { expect { subject }.not_to(change { Thought.count }) }
        it { expect(result[:errors]).to eq file_processing_errors }
        it { expect(result[:entity]).to eq nil }
      end
    end
  end
end
