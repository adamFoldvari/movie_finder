require 'uri'
require 'net/http'
require 'rails_helper'

RSpec.describe MoviesClient do
  subject(:movies_client) { described_class.new }

  describe '#search' do
    it 'returns the response from MOVIES_API_URL' do
      stub_movies_api 'search_query', 'Response data'

      response = movies_client.search 'search_query'

      expect(response.code).to eq(200)
      expect(response.body).to eq('Response data')
    end

    it 'sends an HTTP GET request with pagination parameters' do
      stub_movies_api 'search_query', 'Response data', 200, 2

      response = movies_client.search('search_query', 2)

      expect(response.code).to eq(200)
      expect(response.body).to eq('Response data')
    end

    it 'handles network errors gracefully' do
      allow(ENV).to receive(:[]).with('MOVIES_API_URL').and_return('https://example.com/api/movies')
      allow(ENV).to receive(:[]).with('MOVIES_API_KEY').and_return('your_api_key')
      stub_request(:get, 'https://example.com/api/movies?page=1&query=search_query').to_raise(Net::OpenTimeout)

      expect { movies_client.search 'search_query' }.to raise_error(Net::OpenTimeout)
    end

    it 'handles non-successful HTTP responses gracefully' do
      stub_movies_api 'search_query', 'Not Found', 404

      response = movies_client.search'search_query'

      expect(response.code).to eq(404)
      expect(response.body).to eq('Not Found')
    end

    describe '#caching' do
      let(:query) { 'search_query' }
      let(:cache_key) { "https://example.com/api/movies?query=#{query}&page=1" }
      let(:expected_response) { {"code":200,"body":"Response data"} }

      before do
        stub_movies_api 'search_query', 'Response data', 200
        movies_client.search 'search_query'
      end

      it 'caches the response' do
        expect(Rails.cache.read(cache_key)).to eq(expected_response)
      end

      it 'uses the cache on a second request' do
        expect(Rails.cache).not_to receive(:write).with(cache_key, expected_response)
        allow(Rails.cache).to receive(:write).and_call_original

        stub_movies_api 'search_query', 'Something else', 200
        movies_client.search 'search_query'

        expect(Rails.cache.read(cache_key)).to eq(expected_response)
        expect(Rails.cache.read('cache_hit_counter')).to eq(1)
      end
    end
  end
end
