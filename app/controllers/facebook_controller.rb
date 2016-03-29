class FacebookController < ApplicationController
  requires_user only: [:connect, :disconnect]
  before_action :detect_admin_signup, only: [:signup]

  def login
    require_user_info(login_users_url, code: params[:code]) do |user_info|
      if authenticate_with_facebook(user_info[:id])
        redirect_to discussions_url
      elsif Sugar.config.signups_allowed
        signup
      else
        flash[:notice] = "Could not find your Facebook account"
        redirect_to login_users_url
      end
    end
  end

  def facebook_session_data(user_info)
    {
      facebook_uid: user_info[:id],
      email:        user_info[:email],
      realname:     user_info[:name],
      username:     (user_info[:username] || user_info[:name])
    }
  end

  def signup
    require_user_info(
      new_user_url, code: params[:code], redirect_uri: signup_facebook_url
    ) do |user_info|
      session[:facebook_user_params] = facebook_session_data(user_info)
      redirect_to new_user_url
    end
  end

  def connect
    redirect_url = edit_user_page_url(id: current_user.username,
                                      page: "services")
    require_user_info(
      redirect_url, code: params[:code], redirect_uri: connect_facebook_url
    ) do |user_info|
      if user_info[:id]
        current_user.update_attribute(:facebook_uid, user_info[:id])
      end
      redirect_to redirect_url
    end
  end

  def disconnect
    current_user.update_attribute(:facebook_uid, nil)
    flash[:notice] = "You have disconnected your Facebook account"
    redirect_to edit_user_page_url(
      id: current_user.username,
      page: "services"
    )
  end

  protected

  def authenticate_with_facebook(facebook_uid)
    user = User.find_by_facebook_uid(facebook_uid)
    if user
      @current_user = user
    else
      false
    end
  end

  def detect_admin_signup
    @admin_signup = true if User.count(:all) == 0
  end

  def fb_profile_url(access_token)
    "https://graph.facebook.com/me?access_token=#{access_token}"
  end

  def fb_access_token_url(code, redirect_uri)
    "https://graph.facebook.com/oauth/access_token" \
      "?client_id=#{Sugar.config.facebook_app_id}" \
      "&redirect_uri=#{redirect_uri}" \
      "&client_secret=#{Sugar.config.facebook_api_secret}" \
      "&code=#{code}"
  end

  def get_access_token(code, options = {})
    return nil unless code

    options[:redirect_uri] ||= login_facebook_url

    begin
      response = open(fb_access_token_url(code, options[:redirect_uri])).read
      CGI.parse(response)["access_token"].first if response =~ /access_token=/
    rescue => e
      logger.error "Facebook authentication error: #{e.message}"
      nil
    end
  end

  def get_user_info(options = {})
    access_token = options[:access_token] ||
                   get_access_token(options[:code], options)
    return unless access_token
    begin
      response = open(fb_profile_url(access_token)).read
      JSON.parse(response).symbolize_keys
    rescue => e
      logger.error "Facebook API error: #{e.message}"
      nil
    end
  end

  def require_user_info(redirect_url, opts = {})
    @user_info ||= get_user_info(opts)
    if @user_info
      yield @user_info
    else
      flash[:error] = "Failed to verify your Facebook account"
      redirect_to redirect_url
    end
  end
end
