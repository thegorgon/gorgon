class Site::BlogController < Site::BaseController
  def index
    @posts = Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def show
    @post = Tumblr::Item.find(params[:id])
  end
end