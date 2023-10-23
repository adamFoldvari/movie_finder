require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    let(:query) { 'batman' }

    context 'there is no query and result' do
      before do
        get movies_path
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders input box and search button' do
        expect(response.body).to have_tag('form', with: { action: movies_path, method: 'get'}) do
          with_tag 'input', with: { type: 'text', name: 'query', required: 'required' }
          with_tag 'button', text: 'Search', with: { type: 'submit' }
        end
      end

      it 'does not set an notice flash' do
        expect(flash[:notice]).to be_nil
      end

      it 'does not render a notice message' do
        expect(response.body).not_to have_tag('div.alert.alert-success.my-3.d-inline-block') do
          without_tag 'span'
        end
      end

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('div#movies.row.mt-4')
        expect(response.body).not_to have_tag('div.movie.card')
      end

      it 'does not render pagination controls' do
        expect(response.body).not_to have_tag('nav.mt-4') do
          without_tag 'ul.pagination'
        end
      end
    end

    context 'there is a query and result' do
      context 'with results from the API' do
        before do
          stub_movies_api query, {results: [{title: 'Batman', poster_path: 'poster.jpg'}]}.to_json
          get movies_path, params: { query: query }
        end

        it 'renders movie list' do
          expect(response.body).to have_tag('div#movies.row') do
            with_tag('div.col-md-3.mb-4') do
              with_tag 'div.card' do
                with_tag 'img.card-img-top', with: { src: 'https://image.tmdb.org/t/p/w300/poster.jpg' }
                with_tag 'h5.card-title', text: 'Batman'
              end
            end
          end
        end

        it 'sets a notice flash' do
          expect(flash[:notice]).to eq("Results fetched from the API.")
        end

        it 'renders a notice message' do
          expect(response.body).to have_tag('div.alert.alert-success.my-3.d-inline-block') do
            with_tag 'span', text: 'Results fetched from the API.'
          end
        end
      end

      context 'with results from the server' do
        before do
          stub_movies_api query, {results: [{title: 'Batman', poster_path: 'poster.jpg'}]}.to_json
          get movies_path, params: { query: query }
          get movies_path, params: { query: query }
        end

        it 'renders movie list' do
          expect(response.body).to have_tag('div#movies.row') do
            with_tag('div.col-md-3.mb-4') do
              with_tag 'div.card' do
                with_tag 'img.card-img-top', with: { src: 'https://image.tmdb.org/t/p/w300/poster.jpg' }
                with_tag 'h5.card-title', text: 'Batman'
              end
            end
          end
        end

        it 'sets a notice flash' do
          expect(flash[:notice]).to eq("Results fetched from the server.")
        end

        it 'renders a notice message' do
          expect(response.body).to have_tag('div.alert.alert-success.my-3.d-inline-block') do
            with_tag 'span', text: 'Results fetched from the server.'
          end
        end
      end

      context 'without pagination' do
        before do
          stub_movies_api query, {results: [{title: 'Batman', poster_path: 'poster.jpg'}]}.to_json
          get movies_path, params: { query: query }
        end

        it 'does not render pagination controls' do
          expect(response.body).not_to have_tag('nav.mt-4') do
            without_tag 'ul.pagination'
          end
        end
      end

      context 'with pagination' do
        context 'pagination on the first page' do
          before do
            stub_movies_api query, { "results": [],  "total_pages": 2 }.to_json
            get movies_path, params: { query: query }
          end

          it 'renders pagination button for next page' do
            expect(response.body).to have_tag('nav.mt-4') do
              with_tag 'ul.pagination' do
                with_tag 'li.page-item.disabled' do
                  with_tag 'p.page-link', text: "Page 1 of 2"
                end
                with_tag 'li.page-item' do
                  with_tag 'a.page-link', text: 'Next', with: { href: movies_path(query: query, page: 2) }
                end
              end
            end
          end
        end

        context 'pagination on the middle page' do
          before do
            stub_movies_api query, { "results": [], "total_pages": 3 }.to_json, 200, 2
            get movies_path, params: { query: query, page: 2 }
          end

          it 'renders pagination controls' do
            expect(response.body).to have_tag('nav.mt-4') do
              with_tag 'ul.pagination' do
                with_tag 'li.page-item' do
                  with_tag 'a.page-link', text: 'Previous', with: { href: movies_path(query: query, page: 1) }
                end
                with_tag 'li.page-item.disabled' do
                  with_tag 'p.page-link', text: "Page 2 of 3"
                end
                with_tag 'li.page-item' do
                  with_tag 'a.page-link', text: 'Next', with: { href: movies_path(query: query, page: 3) }
                end
              end
            end
          end
        end

        context 'pagination on the last page' do
          before do
            stub_movies_api query, { "results": [], "total_pages": 2 }.to_json, 200, 2
            get movies_path, params: { query: query, page: 2 }
          end

          it 'renders pagination controls' do
            expect(response.body).to have_tag('nav.mt-4') do
              with_tag 'ul.pagination' do
                with_tag 'li.page-item' do
                  with_tag 'a.page-link', text: 'Previous', with: { href: movies_path(query: query, page: 1) }
                end
                with_tag 'li.page-item.disabled' do
                  with_tag 'p.page-link', text: "Page 2 of 2"
                end
              end
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
        expect(response.body).to have_tag('div.alert.alert-danger.my-3') do
          with_tag 'span', text: 'Error: 404'
        end
      end

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('div#movies.row.mt-4')
        expect(response.body).not_to have_tag('div.movie.card')
      end

      it 'does not render pagination controls' do
        expect(response.body).not_to have_tag('nav.mt-4') do
          without_tag 'ul.pagination'
        end
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
        expect(response.body).to have_tag('div.alert.alert-danger.my-3') do
          with_tag 'span', text: 'Network error: Unable to connect to the movie database API.'
        end
      end

      it 'does not render movie list' do
        expect(response.body).not_to have_tag('div#movies.row.mt-4')
        expect(response.body).not_to have_tag('div.movie.card')
      end

      it 'does not set an notice flash' do
        expect(flash[:notice]).to be_nil
      end

      it 'does not render a notice message' do
        expect(response.body).not_to have_tag('div.alert.alert-success.my-3.d-inline-block') do
          without_tag 'span'
        end
      end

      it 'does not render pagination controls' do
        expect(response.body).not_to have_tag('nav.mt-4') do
          without_tag 'ul.pagination'
        end
      end
    end
  end
end
