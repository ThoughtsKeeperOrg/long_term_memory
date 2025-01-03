# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Thoughts::Associations', type: :request do
  let(:parsed_body) { JSON.parse(response.body) }

  describe 'GET /index' do
    let!(:thought) { FactoryBot.create(:thought) }
    let!(:associated_thoughts) { FactoryBot.build_list(:thought, 2) }

    before do
      service_result = { errors: [], items: associated_thoughts }
      allow_any_instance_of(Thoughts::Services::GetAssociated).to receive(:call)
                                                              .with(thought.id.to_s)
        .and_return(service_result)
    end

    subject! { get("/api/associations/#{thought.id}") }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to eq associated_thoughts.to_json }
  end
end
