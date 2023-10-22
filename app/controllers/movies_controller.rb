class MoviesController < ApplicationController
  def index
    @current_page = (params[:page] || 1).to_i
    response = MoviesClient.new.search(params[:query], @current_page)
    handle_response(response)
  rescue Net::OpenTimeout
    flash[:alert] = "Network error: Unable to connect to the movie database API."
  end

  private

  def handle_response(response)
    if response.code == 200
      parse_response(response)
    else
      flash[:alert] = "Error: #{response.code}"
    end
  end

  def parse_response(response)
    body = JSON.parse(response.body)
    @movies = body["results"]
    @total_pages = body["total_pages"]
  end
end
