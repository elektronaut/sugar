class FacebookController < ApplicationController

  requires_user :only => [:connect, :disconnect]
  before_filter :detect_admin_signup, :only => [:signup]

  protected

    def detect_admin_signup
      @admin_signup = true if User.count(:all) == 0
    end

    def get_access_token(code, options={})
      return nil unless code

      options[:redirect_uri] ||= login_facebook_url

      access_token_url = "https://graph.facebook.com/oauth/access_token" +
                          "?client_id=#{Sugar.config(:facebook_app_id)}" +
                          "&redirect_uri=#{options[:redirect_uri]}" +
                          "&client_secret=#{Sugar.config(:facebook_api_secret)}" +
                          "&code=#{code}"
      begin
        response = open(access_token_url).read
        if response =~ /access_token=/
          CGI::parse(response)['access_token'].first
        else
          nil
        end
      rescue => e
        logger.error "Facebook authentication error: #{e.message}"
        nil
      end
    end

    def get_user_info(options={})
      if options[:code]
        options[:access_token] ||= get_access_token(options[:code], options)
      end
      if options[:access_token]
        begin
          response = open("https://graph.facebook.com/me?access_token=#{options[:access_token]}").read
          data = JSON.parse(response).symbolize_keys
        rescue => e
          logger.error "Facebook API error: #{e.message}"
          nil
        end
      else
        nil
      end
    end

  public

    def login
      if @user_info ||= get_user_info(:code => params[:code])

        # User exists
        if user = User.find_by_facebook_uid(@user_info[:id])
          @current_user = user
          store_session_authentication
          redirect_to discussions_url and return

        # Go to signup if allowed
        elsif Sugar.config(:signups_allowed)
          signup and return

        else
          flash[:notice] = "Could not find your Facebook account"
          redirect_to login_users_url and return
        end
      else
        flash[:error] = "Failed to verify your Facebook account"
        redirect_to login_users_url and return
      end
    end

    def signup
      if @user_info ||= get_user_info(:code => params[:code], :redirect_uri => signup_facebook_url)
        session[:user_params] = {
          :facebook_uid => @user_info[:id],
          :email        => @user_info[:email],
          :realname     => @user_info[:name],
          :username     => (@user_info[:username] || @user_info[:name])
        }
      else
        flash[:error] = "Failed to verify your Facebook account"
      end
      redirect_to new_user_url and return
    end

    def connect
      if @user_info ||= get_user_info(:code => params[:code], :redirect_uri => connect_facebook_url)
        @current_user.update_attribute(:facebook_uid, @user_info[:id]) if @user_info[:id]
      else
        flash[:error] = "Failed to verify your Facebook account"
      end
      redirect_to edit_user_page_url(
        :id   => @current_user.username,
        :page => 'services'
      ) and return
    end

    def disconnect
      @current_user.update_attribute(:facebook_uid, nil)
      flash[:notice] = "You have disconnected your Facebook account"
      redirect_to edit_user_page_url(
        :id   => @current_user.username,
        :page => 'services'
      ) and return
    end
end