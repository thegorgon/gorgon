class Site::ProjectsController < Site::BaseController
  def index
  end
  
  def show
    @project = params[:id]
  end
end