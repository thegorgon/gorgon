Gorgon::Application.routes.draw do
  scope :module => "site" do
    controller 'home' do
      get 'about', :action => 'about'
    end
    controller 'blog' do
      get 'blog', :action => 'index'
      get 'blog/:id', :action => 'show', :as => "blog_post"
    end
    get "sitemap(.:format)", :to => "sitemaps#show", :constraints => {:format => :xml}, :as => "sitemap"
  end
  
  root :to => "site/home#index"
end
