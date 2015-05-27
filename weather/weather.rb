#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
require 'json'

set :bind, '0.0.0.0'

IS_METRIC = true

# The URI to do a temperature lookup for the specified city.
# Returns a JSON document with city name, country and temperature.
get '/weather/:city' do
  "Weather: #{params['city']}"
  result = lookup_weather(params['city'])
  puts result
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
  params = { :q => city, :units => "metric" }
  uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# Converts JSON result from API call into a smaller JSON document
def convert_to_JSON(city, response)
  output = JSON.parse(response)
  result = {  :city => output['name'],
              :country => output['sys']['country'],
              :temp => output['main']['temp'],
              :format => (IS_METRIC ? "Celcius" : "Farenheit") }
  result.to_json
end

