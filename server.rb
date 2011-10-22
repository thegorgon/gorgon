module Gorgon
  class Server < Sinatra::Base
    cattr_accessor :sprockets
    set :public_path, Proc.new { File.join(root, "public") }
    set :views, Proc.new { File.join(root, "app", "views") }
    
    helpers TagHelper,
            MetaHelper, 
            AssetsHelper, 
            ApplicationHelper
    
    before do
      set_title "the gorgon lab - rants and ravings from the mind of jesse reiss"
      set_keywords "jesse reiss", "the gorgon lab", "gorgon", "technology", "entrepreneurship", "blog"
      set_description "the gorgon lab is the personal website and blog of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
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
      Blog.refresh!
      redirect '/blog'
    end
    
    get '/blog' do
      set_namespace "site_blog_index"
      @posts = Blog.page(params[:page])
      haml :blog, :locals => {:posts => @posts}
    end
    
    get '/blog.xml' do
      @posts = Blog.all
      builder :blog, :locals => {:posts => @posts}
    end

    get '/blog/:slug' do
      set_namespace "site_blog_show"
      @post = Blog.find(params[:slug])
      raise Sinatra::NotFound unless @post && @post.respond_to?(:to_tumblr)
      
      prepend_title remove_tags(@post.to_tumblr.title)
      append_keywords @post.to_tumblr.tags
      set_description "#{(truncate_string(remove_tags(@post.to_tumblr.body), 200).strip)}..."
      
      haml :post, :locals => {:post => @post, :show_comments => true, :first_or_last => "first"}
    end
        
    get '/twitter' do
      set_namespace "site_home_twitter"
      @ext = "http://www.twitter.com/#!/jessereiss"
      haml :twitter
    end
    
    get '/projects' do
      set_namespace "site_projects_index"
      haml :projects
    end
    
    get %r{/422(.html)?} do
      set_namespace "site_errors_unprocessable"
      haml :'422'
    end
    
    get %r{/404(.html)?} do
      set_namespace "site_errors_notfound"
      haml :'404'
    end
    
    get %r{/500(.html)?} do
      set_namespace "site_errors_server"
      haml :'500'
    end
    
    error 404, Sinatra::NotFound do
      set_namespace "site_errors_notfound"
      haml :'404'
    end
    
    error 422 do
      set_namespace "site_errors_unprocessable"
      haml :'422'
    end
    
    error 500, Exception do
      set_namespace "site_errors_server"
      haml :'500'
    end
  end
end
