class UsersController < ApplicationController
  module UsersListController
    extend ActiveSupport::Concern

    def index
      @users = User.active
      respond_with(@users) do |format|
        format.mobile {
          @online_users = @users.select{|u| u.online?}
        }
      end
    end

    def banned
      @users  = User.banned.by_username
      respond_with(@users)
    end

    def recently_joined
      @users = User.recently_joined.limit(25)
      respond_with(@users)
    end

    def online
      @users = User.online.by_username
      respond_with(@users)
    end

    def admins
      @users  = User.admins.by_username
      respond_with(@users)
    end

    def xboxlive
      @users = User.xbox_users.by_username
      respond_with(@users)
    end

    def social
      @users = User.social.by_username
      respond_with(@users)
    end

    def top_posters
      @users = User.top_posters.limit(50)
      respond_with(@users)
    end

    def map
    end

    def trusted
      unless @current_user && @current_user.trusted?
        flash[:notice] = "You need to be trusted to view this page!"
      end
      @users = User.trusted.by_username
      respond_with(@users)
    end

  end
end