# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OcrConsumer, type: :consumer do
  let(:thought) { FactoryBot.create(:thought, content: 'before test') }
  let(:image) { FactoryBot.create(:image, thought: thought) }

  subject { OcrConsumer.new.consume }

  before do
    message_double = double(
      key: image.id,
      payload: { 'text' => 'test text' }
    )

    allow_any_instance_of(described_class)
      .to receive(:messages)
      .and_return([message_double])
  end

  it 'updates content of thought' do
    expect { subject }
      .to change { thought.reload.content }
      .to("before test\ntest text")
  end

  it 'publishes event to kafka' do
    subject
    event_payload = { entitity_type: :thought,
                      entity: thought.reload,
                      status: :updated,
                      user_id: 'placeholder-user_id' }.as_json
    expect(karafka.produced_messages.first[:key]).to eq(thought.id.to_s)
    expect(karafka.produced_messages.first[:topic]).to eq('entities_updates')
    expect(JSON.parse(karafka.produced_messages.first[:payload])).to eq(event_payload)
  end

  it { expect { subject }.to change { karafka.produced_messages.size }.by(1) }
end
