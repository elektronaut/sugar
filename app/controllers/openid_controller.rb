# encoding: utf-8

class OpenidController < ApplicationController
  def create
    unless start_openid_session(
      params[:openid_url],
      immediate: false,
      success:   params[:openid_success],
      fail:      params[:openid_success]
    )
      fail_authentication("Not a valid OpenID URL")
    end
  end

  def complete
    case response = openid_complete_response

    # Setup needed
    when ::OpenID::Consumer::SetupNeededResponse
      if setup_url = openid_setup_url(response)
        redirect_to setup_url
        return
      elsif setup_response(response)
        perform_openid_authentication(response)
        return
      end

    # Authentication success
    when ::OpenID::Consumer::SuccessResponse
      session[:authenticated_openid_url] =
        ::OpenID.normalize_url(response.identity_url)
      redirect_to openid_redirect_url
      return

    # Authentication failed
    when ::OpenID::Consumer::FailureResponse
      # Do nothing, let it fail
    end

    fail_authentication
  end

  protected

  def openid_redirect_url
    if session[:openid_redirect_success]
      session[:openid_redirect_success]
    else
      root_url
    end
  end

  def setup_response(response)
    openid_consumer.begin(response.identity_url)
  rescue
    nil
  end

  def openid_setup_url(response)
    response.instance_eval { @setup_url }
  rescue
    nil
  end

  def openid_complete_response
    response_params = params.dup
    response_params.delete(:controller)
    response_params.delete(:action)
    response_params.delete(:format)
    openid_consumer.complete(response_params, complete_openid_url)
  end

  def fail_authentication(message = "OpenID login failed")
    session[:openid_url] = nil
    flash[:notice] = message
    redirect_url = session[:openid_redirect_fail] || root_url
    redirect_to redirect_url
  end
end
