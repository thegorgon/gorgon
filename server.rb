module Gorgon
  class Server < Sinatra::Base
    set :public_path, Proc.new { File.join(root, "public") }
    set :views, Proc.new { File.join(root, "app", "views") }
    
    helpers TagHelper,
            MetaHelper, 
            Sinatra::Sprockets::Helpers, 
            ApplicationHelper,
            Sinatra::ContentFor
    
    before do
      set_title "the gorgon lab - rants and ravings from the mind of jesse reiss"
      set_keywords "jesse reiss", "the gorgon lab", "gorgon", "technology", "entrepreneurship", "blog"
      set_description "the gorgon lab is the personal website and blog of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
      cache_control :public, :max_age => 60
      last_modified settings.environment == :development ? Time.now : settings.start_time
      headers "X-Content-Type-Options" => "nosniff"
    end
    
    after do
      etag settings.revision unless settings.environment == :development || response['ETag'].present?
    end
    
    get '/?' do
      set_namespace "site_home_index"
      hide_header!
      haml :homepage
    end
    
    get "/about" do
      set_namespace "site_home_about"
      haml :about
    end
    
    get '/blog/refresh' do
      etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      Tumblr::Blog.refresh!
      redirect to('/blog'), 301
    end
    
    get '/blog/:slug' do
      set_namespace "site_blog_show"
      @post = Tumblr::Blog.entry(params[:slug])
      raise Sinatra::NotFound unless @post

      last_modified @post.date
      etag @post.etag
      
      prepend_title @post.title
      append_keywords @post.tags
      set_description @post.body.html_strip.max_length(200, '...')
      
      haml :post, :locals => {:post => @post, :show_comments => true, :first_or_last => "first"}
    end
        
    get '/blog' do
      set_namespace "site_blog_index"
      @posts = Tumblr::Blog.page(params[:page]).per_page(3)
      @posts = @posts.tagged_with(params[:tag]) if params[:tag]
      if @posts.length > 0
        last_modified @posts.first.date
        etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      end
      @subnav = :blog
      haml :blog
    end
    
    get '/blog.xml' do
      @posts = Tumblr::Blog.all
      if @posts.length > 0
        last_modified @posts.first.date
        etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      end
      builder :blog
    end

    get '/twitter' do
      set_namespace "site_home_twitter"
      @ext = "http://www.twitter.com/#!/jessereiss"
      haml :twitter
    end
    
    get '/projects' do
      prepend_title "projects"
      set_namespace "site_projects_index"
      @subnav = :projects
      haml :projects
    end
    
    get '/projects/autovalidator' do
      prepend_title "the autovalidator"
      set_namespace "site_projects_autovalidator"
      haml :"projects/autovalidator"      
    end
        
    get %r{/422(.html)?} do
      set_namespace "site_errors_unprocessable"
      status 422
      haml :'422'
    end
    
    get %r{/404(.html)?} do
      set_namespace "site_errors_notfound"
      status 404
      haml :'404'
    end
    
    get %r{/500(.html)?} do
      set_namespace "site_errors_server"
      status 500
      haml :'500'
    end
    
    error 404, Sinatra::NotFound do
      etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      set_namespace "site_errors_notfound"
      status 404
      haml :'404'
    end
    
    error 422 do
      etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      set_namespace "site_errors_unprocessable"
      status 422
      haml :'422'
    end
    
    error 500, Exception do
      etag Digest::SHA1.hexdigest(Time.now.to_i.to_s)
      set_namespace "site_errors_server"
      status 500
      haml :'500'
    end
  end
end
