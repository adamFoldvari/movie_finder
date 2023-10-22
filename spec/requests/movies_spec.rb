require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    before do
      get movies_path
    end

    it 'responds with 200' do
      expect(response).to have_http_status(:ok)
    end
  end
end
