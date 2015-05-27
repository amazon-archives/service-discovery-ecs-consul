#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
require 'json'
require 'resolv'

set :bind, '0.0.0.0'

# The main web page.
get '/' do
  redirect '/index.html'
end

# The URI to do a temperature lookup for the specified city.
# Returns a JSON document with city name, country and temperature.
get '/weather/:city' do
  lookup_weather(params['city'])
end

# The URI to do the stock symbol lookup.
# Returns a JSON document with stock name and price.
get '/stock/:symbol' do
  lookup_stock(params['symbol'])
end

# The URI for the health check
get '/health' do
  "OK"
end

# The function to lookup weather for a particular city.
# Looks up the weather microservice and returns JSON doc
def lookup_weather(city)
  address, port = lookup_service('weather')
  uri = URI.parse(URI.encode("http://#{address}:#{port}/weather/#{city}"))
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# The function to lookup stock price for a particular symbol.
# Looks up the 'stock-price' microservice and returns JSON doc
def lookup_stock(stock)
  address, port = lookup_service('stock-price')
  uri = URI.parse(URI.encode("http://#{address}:#{port}/stock/#{stock}"))
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# Function to return an IP address and port number for a given service name
# Assumes Consul agent is running locally and acting as the default DNS resolver
def lookup_service(service_name)
  resolver = Resolv::DNS.open
  record = resolver.getresource(service_name, Resolv::DNS::Resource::IN::SRV)
  return resolver.getaddress(record.target), record.port
end
