require './config/application'

map '/assets' do
  run Sinatra::Sprockets.environment
end

map '/' do
  run Gorgon::Server
end
