class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Exception, :with => :render_error
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActionController::UnknownController, :with => :render_404
  rescue_from ActionController::UnknownAction, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

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
  
  def module_names
    @module_names ||= params[:controller].split('/').reverse.drop(1).join(" ")
  end
  helper_method :module_names
  
  def log_error(exception)
    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << "  " << clean_backtrace(exception, :silent).join("\n  ")
    Rails.logger.fatal("#{message}\n\n") if Rails.logger
  end

  def render_error(exception)
    handle_error(exception)
    render :template => "/site/errors/500.html.haml", :status => 500, :layout => "twocol"
  end
  
  def clean_backtrace(exception, *args)
    Rails.backtrace_cleaner.clean(exception.backtrace, *args)
  end
  
  def render_404(exception=nil)
    handle_error(exception)
    render :template => "/site/errors/404.html.haml", :status => 404, :layout => "twocol"
  end
  
  def handle_error(exception=nil)
    log_error(exception)
    @exception = exception
    @controller_name = "site_errors"
    @page_namespace = "site_errors_show"
  end
end
