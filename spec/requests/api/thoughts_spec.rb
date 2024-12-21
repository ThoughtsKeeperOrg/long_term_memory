require 'rails_helper'

RSpec.describe "Api::Thoughts", type: :request do
  describe "GET /index" do
    let!(:thoughts) { FactoryBot.create_list(:thought, 2) }

    subject! { get('/api/thoughts') }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to eq thoughts.to_json }
  end
end
