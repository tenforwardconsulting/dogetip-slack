require 'sinatra'
require "sinatra/json"
require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
require './command.rb'
set :bind, '0.0.0.0'

raise "Please set SLACK_API_TOKEN" if ENV['SLACK_API_TOKEN'].nil?

post "/tip" do
  puts params
  raise "NOP" unless params['token'] == ENV['SLACK_API_TOKEN']

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