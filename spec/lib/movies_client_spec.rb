require 'uri'
require 'net/http'
require 'rails_helper'

RSpec.describe MoviesClient do
  subject(:movies_client) { described_class.new }

  before do
    allow(ENV).to receive(:[]).with('MOVIES_API_URL').and_return('https://example.com/api/movies')
    allow(ENV).to receive(:[]).with('MOVIES_API_KEY').and_return('your_api_key')
  end

  describe '#search' do
    it 'sends an HTTP GET request with the proper headers' do
      stub_request(:get, 'https://example.com/api/movies?query=search_query').with(
        headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer your_api_key',
          'Host'=>'example.com',
          'User-Agent'=>'Ruby'
        }
      ).to_return(body: 'Response data', status: 200)

      response = movies_client.search 'search_query'

      expect(response.code).to eq(200)
      expect(response.body).to eq('Response data')
    end

    it 'handles network errors gracefully' do
      stub_request(:get, 'https://example.com/api/movies?query=search_query').to_raise(Net::OpenTimeout)

      expect { movies_client.search 'search_query' }.to raise_error(Net::OpenTimeout)
    end

    it 'handles non-successful HTTP responses gracefully' do
      stub_request(:get, 'https://example.com/api/movies?query=search_query').to_return(body: 'Not Found', status: 404)

      response = movies_client.search'search_query'

      expect(response.code).to eq(404)
      expect(response.body).to eq('Not Found')
    end
  end
end
