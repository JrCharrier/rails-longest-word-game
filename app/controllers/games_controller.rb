require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    @letters = [*('A'..'Z')].shuffle[0,10]
    session[:start_time] = (Time.now).to_f
    session[:letters] = @letters
  end

 def score
    @word = params[:word].upcase
    @end_time = Time.now.to_f
    @time_taken = @end_time - session[:start_time]
    @letters = session[:letters]
    @wordletters = @word.chars
    begin
      api_url = "https://dictionary.lewagon.com/#{@word}"
      response = URI.open(api_url).read
      valid_word = JSON.parse(response)["found"]
    rescue OpenURI::HTTPError => e
      Rails.logger.error "HTTP Error: #{e.message}"
      valid_word = false
    end

    if @wordletters.all? { |letter| @letters.count(letter) >= @word.count(letter) }
      if valid_word
        @message = "Congratulations! #{@word} is a valid English word!"
        @score = (@word.length / @time_taken).round(2)
      else
        @message = "Sorry but #{@word} does not seem to be a valid English word..."
        @score = 0
      end
    else
      @message = "Sorry but #{@word} can't be built out of #{@letters}"
      @score = 0
    end
  end
end
