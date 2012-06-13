# encoding: utf-8

class OpenidController < ApplicationController

  # Start an authentication session
  def create
    unless start_openid_session(
      params[:openid_url], 
      :immediate => false, 
      :success   => params[:openid_success], 
      :fail      => params[:openid_success]
    )
      fail_authentication('Not a valid OpenID URL') and return
    end
  end
  
  # Complete the OpenID authentication
  def complete
    response_params = params.dup
    response_params.delete(:controller)
    response_params.delete(:action)
    response_params.delete(:format)
    response = openid_consumer.complete(response_params, complete_openid_url)

    case response

    # Setup needed
    when ::OpenID::Consumer::SetupNeededResponse
      setup_url = response.instance_eval{ @setup_url } rescue nil
      if setup_url
        redirect_to setup_url and return
      else
        setup_response = openid_consumer.begin(response.identity_url) rescue nil
        if setup_response
          perform_openid_authentication(response) and return
        end
      end

    # Authentication success
    when ::OpenID::Consumer::SuccessResponse
      session[:authenticated_openid_url] = ::OpenID.normalize_url(response.identity_url)
      redirect_url = session[:openid_redirect_success] || root_url
      redirect_to redirect_url and return

    # Authentication failed
    when ::OpenID::Consumer::FailureResponse
      # Do nothing, let it fail
    end

    fail_authentication and return
  end
  
  protected
  
    def fail_authentication(message='OpenID login failed')
      session[:openid_url] = nil
      flash[:notice] = message
      redirect_url = session[:openid_redirect_fail] || root_url
      redirect_to redirect_url
    end
  
end
