require 'uri'
require 'net/http'

class MoviesClient
  CACHE_TIME = 2.minutes

  def initialize(cache_manager = CacheManager.new)
    @cache_manager = cache_manager
    @api_url = ENV['MOVIES_API_URL']
    @api_key = ENV['MOVIES_API_KEY']
  end

  def search(query, page = 1)
    uri = build_uri(query, page)
    request = build_request(uri)

    response = @cache_manager.fetch(uri.to_s, expires_in: CACHE_TIME) do
      response = send_request(request)
      {code: response.code.to_i, body: response.read_body}
    end

    OpenStruct.new(response)
  end

  private

  def build_uri(query, page)
    uri = URI(@api_url)
    query_params = { query: query }
    query_params[:page] = page if page > 1
    uri.query = URI.encode_www_form(query_params)
    uri
  end

  def build_request(uri)
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request
  end

  def send_request(request)
    http = Net::HTTP.new(request.uri.host, request.uri.port)
    http.use_ssl = (request.uri.scheme == 'https')
    http.request(request)
  end
end
