require 'sinatra'

post "/tip" do
  json text: "Ship it!"
end