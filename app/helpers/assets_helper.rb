module AssetsHelper
  def asset_path(source)
    sprocket = Gorgon::Server.sprockets.find_asset(source)
    unless sprocket
      puts "Cannot find sprocket #{source}"
      raise Sinatra::NotFound, "Cannot find sprocket #{source}" 
    end
    "/assets/#{sprocket.digest_path}"
  end
  
  def include_javascripts(sources, options={})
    Array(sources).collect do |source|
      options = {
        :type => "application/javascript", 
        :src => asset_path(source)
      }.merge!(options)
      content_tag(:script, "", options)
    end.join("")
  end
  
  def include_stylesheets(sources, options={})
    Array(sources).collect do |source|
      options = {
        :rel => "stylesheet", 
        :type => "text/css",
        :href => asset_path(source)
      }.merge!(options)
      tag(:link, options)
    end.join("")
  end
end