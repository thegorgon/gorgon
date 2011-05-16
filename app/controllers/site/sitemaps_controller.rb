class Site::SitemapsController < Site::BaseController
  def show
    @posts = Post.paginate(:per_page => 10000, :page => 1)
  end
end