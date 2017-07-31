require 'open-uri'
require 'json'

class GameController < ApplicationController
  def game
    # - Variable declaration -
    @grid = generate_grid(9)
    @start_time = Time.now
    # ------------------------

  end

  def score
    # - Variable declaration -
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    key = "74f1bfd9-dcb1-4d21-b25e-73fbf898e406"
    @attempt = params[:attempt]
    grid = JSON.parse params[:grid]
    raw_json = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{@attempt}").read
    @outcome = {}
    @end_message = ""
    # ------------------------

    # puts all letters to downcase
    grid = grid.join('').downcase
    grid.split('')

    @attempt.downcase!

    # converts from JSON to ruby
    api_data = JSON.parse(raw_json)
    @outcome[:translation] = api_data["outputs"][0]["output"]
    @outcome[:time] = (end_time - start_time).floor

    # checar se a palavra ta dentro do grid?
    if @outcome[:translation] != @attempt
      @outcome[:score] = 1000 * @attempt.size / @outcome[:time]
      @outcome[:message] = "Sweet! Well done!"
      @end_message = "success"
    else
      # word doesn't exist
      @outcome[:translation] = nil
      @outcome[:message] = "Ops! '#{@attempt}' is not an english word."
      @end_message = "warning"
      @outcome[:score] = 0
    end

    attempt_array = @attempt.split('')
    unless attempt_array.all? { |letter| attempt_array.count(letter) <= grid.count(letter) }
      @outcome[:message] = "Naughty Naughty! '#{@attempt}' is not in the grid."
      @end_message = "danger"
      @outcome[:score]   = 0
    end

  end

  def generate_grid(grid_size)
    # generate random grid of letters
    letters = [*"a".."z"]
    random_letters = []

    grid_size.times do |_i|
      random_letters << letters.sample
    end

    # outcome[:time] = end_time - start_time

    return random_letters
  end
end
