class ApplicationController < ActionController::Base
  protect_from_forgery

  # Return the rendered page namespace, derived from the Controller name and rendered template. This identifier
  # can be used as a CSS class/id name and JavaScript variable name.  
  def page_namespace
    @page_namespace ||= "#{controller_name}_#{action_name}"
  end
  helper_method :page_namespace
  
  def controller_name
    @controller_name ||= params[:controller].tr('/','_')
  end
  helper_method :controller_name
end
