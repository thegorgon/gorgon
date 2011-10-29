require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'sinatra/base'
require 'sass/plugin'
require 'sinatra/content_for'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'
require 'active_support/core_ext/class'

(Dir["app/**/*.rb"] + Dir["lib/**/*.rb"]).each do |dir|
  require File.expand_path("../../#{dir}", __FILE__)
end

Tumblr.configure do |config|
  config.blog = "thegorgonlab"
  config.api_key = "1pLfP3eTlFjZi3trs2Medo78EwAaOLxMEAHUsRpfEoOS3nhbd8"
  config.redis = {:host => "localhost", :port => 2811}
end

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
  config.compile = testing
  config.digest = config.compress = !testing
  config.debug = testing

  config.precompile = ['scripts.js', 'vendor.js', 'site.css', /^example\/.+/, /.+\.(png|ico|gif|jpeg|jpg)$/]
end

Sass::Plugin.options[:cache] = false
Sass::Plugin.options[:cache_location] = './tmp/sass-cache'
Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:sass2] = true

Gorgon::Server.set(:start_time, Time.now)
Gorgon::Server.set(:revision, Gorgon::Server.settings.environment == :development ? Digest::SHA1.hexdigest(Time.now.to_i.to_s) : `cat REVISION`.strip)