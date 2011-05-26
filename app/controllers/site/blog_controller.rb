class Site::BlogController < Site::BaseController
  def index
    @posts = Post.order("created_at DESC").paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def show
    @post = Post.by_slug(params[:id])
  end
  
  def refresh_all
    Post.refresh!
    redirect_to blog_path
  end
  
  def refresh
    @post = Post.by_slug(params[:id])
    @post.refresh!
    redirect_to blog_post_path(@post)
  end
end