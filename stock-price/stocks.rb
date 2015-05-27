#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
require 'json'
require 'csv'

set :bind, '0.0.0.0'

# The URI to do the stock symbol lookup.
# Returns a JSON document with stock name and price.
get '/stock/:name' do
  "Stock: #{params['name']}"
  result = lookup_stock(params['name'])
  puts result
  convert_to_JSON(params['name'], result) if !result.nil?
end

# The URI for the health check
get '/health' do
  "OK"
end

# Function to do the stock price lookup.
# Makes a call to the Yahoo Finance API and returns result
def lookup_stock(name)
  uri = URI("http://download.finance.yahoo.com/d/quotes.csv?")
  params = { :s => name, :f => 'nl1r' }
  uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# Converts CSV output from API call into a JSON document
def convert_to_JSON(name, response)
  output = CSV.parse(response).flatten
  result = {  :symbol => name,
              :name => output[0],
              :price => output[1] }
  result.to_json
end
