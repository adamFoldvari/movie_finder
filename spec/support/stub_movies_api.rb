def stub_movies_api(query = nil, response_body = {results: []}.to_json, response_status = 200, page = 1)
  allow(ENV).to receive(:[]).with('MOVIES_API_URL').and_return('https://example.com/api/movies')
  allow(ENV).to receive(:[]).with('MOVIES_API_KEY').and_return('your_api_key')

  uri = URI('https://example.com/api/movies')
  uri.query = URI.encode_www_form(query: query, page: page)

  stub_request(:get, uri).with(
    headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Bearer your_api_key',
      'Host'=>'example.com',
      'User-Agent'=>'Ruby'
    }
  ).to_return(body: response_body, status: response_status)
end
