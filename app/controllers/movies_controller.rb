class MoviesController < ApplicationController
  def index
    if params[:query].present?
      set_results_source_flash_message do
        @current_page = (params[:page] || 1).to_i
        response = MoviesClient.new.search(params[:query], @current_page)
        handle_response(response)
      end
    end
  rescue Net::OpenTimeout
    flash[:notice] = nil
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

  def counter
    CacheManager.new.counter
  end

  def set_results_source_flash_message
    initial_counter = counter
    yield
    if params[:query].present?
      flash[:notice] = counter > initial_counter ? "Results fetched from the server." : "Results fetched from the API."
    end
  end
end
