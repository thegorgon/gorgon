class Site::HomeController < Site::BaseController  
  def about
  end
  
  def index
    render :layout => "application"
  end
  
  def twitter
    @ext = "http://www.twitter.com/#!/jessereiss"
  end  
end