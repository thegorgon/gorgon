class Site::HomeController < Site::BaseController  
  def about
  end
  
  def index
    redirect_to blog_path
  end
  
  def twitter
    @ext = "http://www.twitter.com/#!/jessereiss"
  end
end