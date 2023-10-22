require 'uri'
require 'net/http'
require 'rails_helper'

RSpec.describe MoviesClient do
  subject(:movies_client) { described_class.new }

  describe '#search' do
    it 'sends an HTTP GET request with the proper headers' do
      stub_movies_api 'search_query', 'Response data'

      response = movies_client.search 'search_query'

      expect(response.code).to eq(200)
      expect(response.body).to eq('Response data')
    end

    it 'handles network errors gracefully' do
      allow(ENV).to receive(:[]).with('MOVIES_API_URL').and_return('https://example.com/api/movies')
      allow(ENV).to receive(:[]).with('MOVIES_API_KEY').and_return('your_api_key')
      stub_request(:get, 'https://example.com/api/movies?query=search_query').to_raise(Net::OpenTimeout)

      expect { movies_client.search 'search_query' }.to raise_error(Net::OpenTimeout)
    end

    it 'handles non-successful HTTP responses gracefully' do
      stub_movies_api 'search_query', 'Not Found', 404

      response = movies_client.search'search_query'

      expect(response.code).to eq(404)
      expect(response.body).to eq('Not Found')
    end
  end
end
