class MoviesController < ApplicationController
  def index
    response = MoviesClient.new.search(params[:query])

    if response.code == 200
      @movies = JSON.parse(response.body)["results"]
    else
      flash[:alert] = "Error: #{response.code}"
    end
  rescue Net::OpenTimeout
    flash[:alert] = "Network error: Unable to connect to the movie database API."
  end
end
