# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authenticate

  helper :all # include all helpers, all the time
  protect_from_forgery

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected

  def current_user=(user)
    session[:user] = user.id
  end

  def current_user
    User.find(session[:user].to_i) if session[:user]
  end
  helper_method :current_user

  def authenticate
    unless current_user
      session[:redirect_to] = request.url
      settings = SamlController.get_saml_settings
      saml_request = Onelogin::Saml::Authrequest.new
      redirect_to(saml_request.create(settings))
    end
  end
end
