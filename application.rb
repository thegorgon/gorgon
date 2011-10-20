require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'sinatra/base'
require 'haml'
require 'redis'
require 'redis/objects'
require 'tumblr'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object'
require 'active_support/core_ext/class'

(Dir["app/**/*.rb"] + Dir["lib/**/*.rb"]).each do |dir|
  require File.expand_path("../#{dir}", __FILE__)
end

$redis = Redis.new(:host => 'localhost', :port => 2811)
Redis::Objects.redis = $redis

Tumblr.user = Tumblr::User.new 'jessereiss@gmail.com', 'medusa'
Tumblr.blog = 'thegorgonlab'

require './server'

if Gorgon::Server.settings.environment != :development
  log_path = File.expand_path("../log/#{Gorgon::Server.settings.environment}.log", __FILE__)
  FileUtils.mkdir_p File.dirname(log_path)
  log = File.new(log_path, 'a')
  $stdout.reopen(log)
  $stderr.reopen(log)
end

Gorgon::Server.sprockets = Sprockets::Environment.new(Gorgon::Server.root)
['stylesheets', 'javascripts', 'images'].each do |dir|
  Gorgon::Server.sprockets.append_path(File.join(Gorgon::Server.root, 'app', 'assets', dir))
end
Gorgon::Server.sprockets.js_compressor = Closure::Compiler.new
Gorgon::Server.sprockets.css_compressor = YUI::CssCompressor.new

Gorgon::Server.sprockets.context_class.instance_eval do
  include AssetsHelper
end
