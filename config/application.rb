require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'sinatra/base'
require 'haml'
require 'redis'
require 'redis/objects'
require 'tumblr'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'
require 'active_support/core_ext/class'

(Dir["app/**/*.rb"] + Dir["lib/**/*.rb"]).each do |dir|
  require File.expand_path("../../#{dir}", __FILE__)
end

$redis = Redis.new(:host => 'localhost', :port => 2811)
Redis::Objects.redis = $redis

Tumblr.user = Tumblr::User.new 'jessereiss@gmail.com', 'medusa'
Tumblr.blog = 'thegorgonlab'

require File.expand_path("../../server", __FILE__)

if Gorgon::Server.settings.environment != :development
  log_path = File.expand_path("../../log/sinatra.log", __FILE__)
  FileUtils.mkdir_p File.dirname(log_path)
  log = File.new(log_path, 'a')
  $stdout.reopen(log)
  $stderr.reopen(log)
end

Sinatra::Sprockets.configure do |config|
  config.app = Gorgon::Server
  
  ['stylesheets', 'javascripts', 'images'].each do |dir|
    config.append_path(File.join('app', 'assets', dir))
  end
  
  testing = Gorgon::Server.settings.environment == :development
  config.digest = config.compress = !testing
  config.debug = testing

  config.precompile = ['scripts.js', 'vendor.js', 'site.css', /.+\.(png|ico|gif|jpeg|jpg)$/]
end

Gorgon::Server.set(:start_time, Time.now)
Gorgon::Server.set(:revision, Gorgon::Server.settings.environment == :development ? Digest::SHA1.hexdigest(Time.now.to_i.to_s) : `cat REVISION`.strip)