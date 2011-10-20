module Gorgon
  class Server < Sinatra::Base
    cattr_accessor :sprockets
    set :public_path, Proc.new { File.join(root, "public") }
    set :views, Proc.new { File.join(root, "app", "views") }
    
    helpers TagHelper,
            MetaHelper, 
            AssetsHelper, 
            ApplicationHelper
    
    get '/?' do
      set_namespace "site_home_index"
      hide_header!
      haml :homepage
    end
    
    get "/about" do
      set_namespace "site_home_about"
      haml :about
    end
    
    get '/blog/:slug' do
      set_namespace "site_blog_show"
      @post = Blog.find(params[:slug])
      raise Sinatra::NotFound unless @post
      haml :post, :locals => {:post => @post, :show_comments => true, :first_or_last => "first"}
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
