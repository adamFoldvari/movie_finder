require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    let(:query) { 'batman' }

    before do
      stub_movies_api
      get movies_path
    end

    it 'responds with 200' do
      expect(response).to have_http_status(200)
    end

    it 'renders input box and search button' do
      expect(response.body).to have_tag('form', with: { action: movies_path, method: 'get' }) do
        with_tag 'input', with: { type: 'text', name: 'query' }
        with_tag 'input', with: { type: 'submit', value: 'Search' }
      end
    end

    context 'there is a result' do
      before do
        stub_movies_api query, {results: [title: 'Batman']}.to_json
        get movies_path, params: { query: query }
      end

      it 'renders movie list' do
        expect(response.body).to have_tag('ul#movies') do
          with_tag 'li.movie', text: 'Batman'
        end
      end
    end

    context 'API returns a non-200 response' do
      before do
        stub_movies_api query, '{}', 404
        get movies_path, params: { query: query }
      end

      it 'sets an alert message' do
        expect(flash[:alert]).to eq('Error: 404')
      end

      it 'renders the flash message' do
        expect(response.body).to have_tag('p.error', text: 'Error: 404')
      end

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('ul#movies')
        expect(response.body).not_to have_tag('li.movie')
      end
    end

    context 'Network error' do
      before do
        allow_any_instance_of(MoviesClient).to receive(:search).and_raise(Net::OpenTimeout)
        get movies_path, params: { query: query }
      end

      it 'sets a network error alert message' do
        expect(flash[:alert]).to eq('Network error: Unable to connect to the movie database API.')
      end

      it 'renders the flash message' do
        expect(response.body).to have_tag('p.error', text: 'Network error: Unable to connect to the movie database API.')
      end

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('ul#movies')
        expect(response.body).not_to have_tag('li.movie')
      end
    end
  end
end
