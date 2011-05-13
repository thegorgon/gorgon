class Site::SitemapsController < Site::BaseController
  def show
    @posts = Tumblr::Item.paginate(:per_page => 10000)
  end
end