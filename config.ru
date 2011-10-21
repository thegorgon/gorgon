require './config/application'

map '/assets' do
  run Gorgon::Server.sprockets
end

map '/' do
  run Gorgon::Server
end
