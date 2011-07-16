class Site::BlogController < Site::BaseController
  def index
    pagination = params.slice("page", "per_page").reverse_merge!("page" => 1).symbolize_keys
    @posts = Post.order("created_at DESC").paginate(pagination)
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