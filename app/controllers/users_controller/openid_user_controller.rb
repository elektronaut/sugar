class UsersController < ApplicationController
  module OpenidUserController
    extend ActiveSupport::Concern

    def update_openid
      if session[:authenticated_openid_url] &&
          @user.update_attribute(
            :openid_url,
            session[:authenticated_openid_url]
          )
        flash[:notice] = "Your OpenID URL was updated!"
        redirect_to user_profile_url(id: @user.username)
      else
        flash[:notice] ||= "OpenID verification failed!"
        redirect_to edit_user_url(id: @user.username)
      end
    end

    private

    def new_openid_url?
      !params[:user][:openid_url].blank? &&
        params[:user][:openid_url] != @user.openid_url
    end

    def initiate_openid_on_create
      if params[:user][:openid_url]
        success = start_openid_session(
          params[:user][:openid_url],
          success: update_openid_user_url(id: @user.username),
          fail: edit_user_page_url(id: @user.username, page: "settings")
        )
        unless success
          flash[:notice] = "WARNING: Your OpenID URL is invalid!"
        end
        success
      else
        false
      end
    end

    def initiate_openid_on_update
      if new_openid_url?
        success = start_openid_session(
          params[:user][:openid_url],
          success: update_openid_user_url(id: @user.username),
          fail: edit_user_page_url(id: @user.username, page: @page)
        )
        unless success
          flash.now[:notice] = "That's not a valid OpenID URL!"
          render action: :edit
        end
        true
      else
        false
      end
    end
  end
end
