require "fileutils"

namespace :assets do
  def ruby_rake_task(task)
    env    = ENV['RACK_ENV'] || 'production'
    args   = [$0, task,"RACK_ENV=#{env}"]
    ruby(*args)
  end

  # We are currently running with no explicit bundler group
  # and/or no explicit environment - we have to reinvoke rake to
  # execute this task.
  def invoke_or_reboot_rake_task(task)
    if ENV['RAILS_GROUPS'].to_s.empty? || ENV['RAILS_ENV'].to_s.empty?
      ruby_rake_task task
    else
      Rake::Task[task].invoke
    end
  end

  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    invoke_or_reboot_rake_task "assets:clean:all"
    invoke_or_reboot_rake_task "assets:precompile:all"
  end

  namespace :precompile do
    task :all => ["environment"] do
      env      = Gorgon::Server.sprockets
      target   = File.join(Gorgon::Server.settings.public_path, "assets")

      manifest = {}
      env.each_logical_path do |logical_path|
        if asset = env.find_asset(logical_path)
          path = asset.digest_path
          manifest[logical_path] = path
          filename = File.join(target, path)
          FileUtils.mkdir_p File.dirname(filename)
          asset.write_to(filename)
          asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/
        end
      end
      File.open("#{target}/manifest.yml", 'wb') do |f|
        YAML.dump(manifest, f)
      end
    end
  end

  desc "Remove compiled assets"
  task :clean do
    invoke_or_reboot_rake_task "assets:clean:all"
  end

  namespace :clean do
    task :all => ["environment"] do
      public_asset_path = File.join(Gorgon::Server.settings.public_path, "assets")
      rm_rf public_asset_path, :secure => true
    end
  end
end
