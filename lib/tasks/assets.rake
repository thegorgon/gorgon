require "fileutils"

namespace :assets do
  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    Rake::Task["assets:clean:all"].invoke 
    Rake::Task["assets:precompile:all"].invoke
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
    Rake::Task["assets:clean:all"].invoke
  end

  namespace :clean do
    task :all => ["environment"] do
      public_asset_path = File.join(Gorgon::Server.settings.public_path, "assets")
      rm_rf public_asset_path, :secure => true
    end
  end
end
