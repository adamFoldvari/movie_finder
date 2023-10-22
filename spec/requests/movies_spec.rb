require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    before do
      get movies_path
    end

    it 'responds with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders input box and search button' do
      expect(response.body).to have_tag('form', with: { action: movies_path, method: 'get' }) do
        with_tag 'input', with: { type: 'text', name: 'query' }
        with_tag 'input', with: { type: 'submit', value: 'Search' }
      end
    end
  end
end
