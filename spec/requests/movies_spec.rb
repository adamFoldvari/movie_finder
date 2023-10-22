require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    let(:query) { 'batman' }

    context 'there is no query and result' do
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

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('ul#movies')
        expect(response.body).not_to have_tag('li.movie')
      end

      it 'does not render pagination controls' do
        expect(response.body).not_to have_tag('div.pagination')
      end
    end

    context 'there is a query and result' do

      context 'without pagination' do
        before do
          stub_movies_api query, {results: [title: 'Batman']}.to_json
          get movies_path, params: { query: query }
        end

        it 'renders movie list' do
          expect(response.body).to have_tag('ul#movies') do
            with_tag 'li.movie', text: 'Batman'
          end
        end

        it 'does not render pagination controls' do
          expect(response.body).not_to have_tag('div.pagination')
        end
      end

      context 'with pagination' do
        context 'pagination on the first page' do
          before do
            stub_movies_api query, { "results": [],  "total_pages": 2 }.to_json
            get movies_path, params: { query: query }
          end

          it 'renders pagination button for next page' do
            expect(response.body).to have_tag('div.pagination') do
              with_tag 'p', text: 'Page 1 of 2'
              with_tag 'a.next', text: 'Next', with: { href: movies_path(query: query, page: 2) }
            end
          end
        end

        context 'pagination on the middle page' do
          before do
            stub_movies_api query, { "results": [], "total_pages": 3 }.to_json, 200, 2
            get movies_path, params: { query: query, page: 2 }
          end

          it 'renders pagination controls' do
            expect(response.body).to have_tag('div.pagination') do
              with_tag 'p', text: 'Page 2 of 3'
              with_tag 'a.prev', text: 'Previous', with: { href: movies_path(query: query, page: 1) }
              with_tag 'a.next', text: 'Next', with: { href: movies_path(query: query, page: 3) }
            end
          end
        end

        context 'pagination on the last page' do
          before do
            stub_movies_api query, { "results": [], "total_pages": 2 }.to_json, 200, 2
            get movies_path, params: { query: query, page: 2 }
          end

          it 'renders pagination controls' do
            expect(response.body).to have_tag('div.pagination') do
              with_tag 'p', text: 'Page 2 of 2'
              with_tag 'a.prev', text: 'Previous', with: { href: movies_path(query: query, page: 1) }
            end
          end
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
