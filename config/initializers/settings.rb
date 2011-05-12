Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:sass2] = true
Sass::Plugin.options[:template_location] = File.join(Rails.root, 'app', 'sass')
ActiveRecord::Base.include_root_in_json = false

Tumblr.user = Tumblr::User.new 'jessereiss@gmail.com', 'medusa'
Tumblr.blog = 'thegorgonlab'