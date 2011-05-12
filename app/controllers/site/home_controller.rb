class Site::HomeController < Site::BaseController  
  def about
  end
  
  def index
    @post = Tumblr::Item.paginate(:per_page => 1).first
  end
end