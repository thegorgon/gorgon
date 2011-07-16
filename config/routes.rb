Gorgon::Application.routes.draw do
  scope :module => "site" do
    controller 'home' do
      get 'about', :action => 'about'
      get 'twitter', :action => 'twitter'
    end
    controller 'blog' do
      get 'blog', :action => 'index'
      get 'blog/refresh', :action => 'refresh_all', :as => "refresh_blog"
      get 'blog/:id/refresh', :action => 'refresh', :as => "refresh_blog_post"
      get 'blog/:id', :action => 'show', :as => "blog_post"
    end
    controller 'comments' do
      get  'blog/:post_id/comments', :action => 'index', :as => "blog_post_comments"
      post 'blog/:post_id/comments', :action => 'create'
      delete 'blog/:post_id/comments/:id', :action => 'destroy', :as => "blog_post_comment"
    end
    get "sitemap(.:format)", :to => "sitemaps#show", :constraints => {:format => :xml}, :as => "sitemap"
  end
  
  root :to => "site/home#index"
  match "500.html", :to => "site/errors#server_error"
  match "404.html", :to => "site/errors#not_found"
  match "422.html", :to => "site/errors#unprocessable"
  match "*path", :to => "site/errors#not_found"
end
