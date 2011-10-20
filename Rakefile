require 'rake'

task :environment do
  require File.expand_path('../application', __FILE__)
end

Dir['lib/tasks/**/*.rake'].each do |dir|
  load File.expand_path("../#{dir}", __FILE__)
end