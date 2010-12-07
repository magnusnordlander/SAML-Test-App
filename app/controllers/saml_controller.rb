class SamlController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :consume
  skip_before_filter :authenticate, :only => :consume

  def consume
    saml_response = Onelogin::Saml::Response.new(params[:SAMLResponse])

    # insert identity provider discovery logic here
    saml_response.settings = SamlController.get_saml_settings

    if saml_response.is_valid?
      self.current_user = User.find_by_email!(saml_response.name_id)
      redirect_to(session[:redirect_to])
    else
      render :text => CGI::escapeHTML(saml_response.inspect)
    end
  end

  protected

  def self.get_saml_settings
    settings = Onelogin::Saml::Settings.new

    settings.assertion_consumer_service_url = "http://localhost/saml"
    settings.issuer                         = "SAML Test App"
    settings.idp_sso_target_url             = "http://...."
    settings.idp_cert_fingerprint           = "AA:BB:CC..."
    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    settings
  end
end