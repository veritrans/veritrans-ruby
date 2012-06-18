require 'sinatra'
get '/hi' do
  "Hello World!"
end

post '/hi' do
  puts params.inspect
  puts params.keys
end
