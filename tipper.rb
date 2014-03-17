require 'sinatra'
require "sinatra/json"
require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
require './command.rb'
set :bind, '0.0.0.0'


post "/tip" do
  command = new Command(params)

  json text: command.result
end


get "/" do
  "it works!"
end