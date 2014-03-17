require 'sinatra'
require "sinatra/json"
require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
require './command.rb'
set :bind, '0.0.0.0'


post "/tip" do
  puts params
  begin
    command = Command.new(params)
    command.perform
    json text: command.result, icon_emoji: command.icon_emoji
  rescue Exception => ex
    json text: "so error: #{ex.message}", icon_emoji: ":japanese_goblin:"
  end
end


get "/" do
  "it works!"
end