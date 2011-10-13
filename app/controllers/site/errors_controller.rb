class Site::ErrorsController < Site::BaseController      
  def not_found
    render :template => "/site/errors/404.html.haml", :status => 404, :layout => "twocol"
  end
  
  def unprocessable
    render :template => "/site/errors/422.html.haml", :status => 422, :layout => "twocol"
  end
  
  def server_error
    render :template => "/site/errors/500.html.haml", :status => 500, :layout => "twocol"
  end
end