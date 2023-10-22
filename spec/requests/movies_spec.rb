require 'rails_helper'

RSpec.describe "Movies", type: :request do
  before do
    allow(ENV).to receive(:[]).with('MOVIES_API_URL').and_return('https://example.com/api/movies')
    allow(ENV).to receive(:[]).with('MOVIES_API_KEY').and_return('your_api_key')

    stub_request(:get, 'https://example.com/api/movies?query').with(
      headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>'Bearer your_api_key',
        'Host'=>'example.com',
        'User-Agent'=>'Ruby'
      }
    ).to_return(body: '{}', status: 200)
  end

  describe "GET /index" do
    before { get movies_path }

    it 'responds with 200' do
      expect(response).to have_http_status(200)
    end

    it 'renders input box and search button' do
      expect(response.body).to have_tag('form', with: { action: movies_path, method: 'get' }) do
        with_tag 'input', with: { type: 'text', name: 'query' }
        with_tag 'input', with: { type: 'submit', value: 'Search' }
      end
    end
  end
end
