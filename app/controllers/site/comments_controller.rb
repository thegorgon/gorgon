class Site::CommentsController < Site::BaseController
  def index
    @post = Post.by_slug(params[:post_id])
    @comments = @post.comments.paginate(:page => params[:page], :per_page => params[:per_page])
    render :json => {:comments => @comments}
  end
  
  def create
    @post = Post.by_slug(params[:post_id])
    @comment = @post.comments.new(params[:comment])
    if @comment.save
      render :json => {:success => true, :html => render_to_string(:partial => "/site/blog/comment.html", :object => @comment)}
    else
      render :json => {:success => false}
    end
  end
  
  def destroy
  end
end