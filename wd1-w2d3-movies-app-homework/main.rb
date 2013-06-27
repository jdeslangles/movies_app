require 'pry'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'httparty'
require 'json'

get '/' do
  if params[:title]
    name = params[:title].gsub(' ', '+')
    url = "http://www.omdbapi.com/?t=#{name}"
    html = HTTParty.get(url)
    @hash = JSON(html)
  end

  erb :movie
end
