#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
require 'json'
require 'logger'

set :bind, '0.0.0.0'

# do the configuration of the web server
configure do

  enable :logging

  # get the temperature scale from an enviornment variable
  temp_scale = ENV['TEMP_SCALE']
  case temp_scale
  when 'C'
    set :is_metric => true
  when 'F'
    set :is_metric => false
  else
    set :is_metric => true
  end

  # get the Open Weathermap API Key from an enviornment variable
  set :api_key => ENV['API_KEY']
end


# The URI to do a temperature lookup for the specified city.
# Returns a JSON document with city name, country and temperature.
get '/weather/:city' do
  "Weather: #{params['city']}"
  result = lookup_weather(params['city'])
  logger.info "Response from external API is: #{result}"
  convert_to_JSON(params['city'], result) if !result.nil?
end

# The URI for the health check
get '/health' do
  "OK"
end

# Function to do the city weather lookup.
# Makes a call to the Open Weather Map API and returns result
def lookup_weather(city)
  uri = URI("http://api.openweathermap.org/data/2.5/weather")
  params = { :q => city, :units => (settings.is_metric ? "metric" : "imperial"), :APPID => settings.api_key }
  uri.query = URI.encode_www_form(params)
  logger.info "URI is: #{uri}"
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# Converts JSON result from API call into a smaller JSON document
def convert_to_JSON(city, response)
  output = JSON.parse(response)
  result = {  :city => output['name'],
              :country => output['sys']['country'],
              :temp => output['main']['temp'],
              :format => (settings.is_metric ? "Celsius" : "Farenheit") }
  result.to_json
end
