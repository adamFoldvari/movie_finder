require 'uri'
require 'net/http'

class MoviesClient
  def initialize
    @api_url = ENV['MOVIES_API_URL']
    @api_key = ENV['MOVIES_API_KEY']
  end

  def search(query)
    uri = build_uri(query)
    request = build_request(uri)

    response = send_request(request)

    OpenStruct.new(code: response.code.to_i, body: response.read_body)
  end

  private

  def build_uri(query)
    uri = URI(@api_url)
    uri.query = URI.encode_www_form(query: query)
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
