# frozen_string_literal: true

class UsersController < ApplicationController
  module UsersListController
    extend ActiveSupport::Concern

    def index
      @users = User.active_and_memorialized.by_username
      respond_with(@users) do |format|
        format.mobile do
          @online_users = @users.select(&:online?)
        end
      end
    end

    def deactivated
      @users = User.deactivated.by_username
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
      @users = User.admins.by_username
      respond_with(@users)
    end

    def social
      @users = User.social.by_username
      respond_with(@users)
    end

    def gaming
      @users = User.gaming.by_username
      respond_with(@users)
    end

    def top_posters
      @users = User.top_posters.limit(50)
      respond_with(@users)
    end

    def map; end

    def trusted
      if current_user&.trusted?
        @users = User.trusted.by_username
        respond_with(@users)
      else
        flash[:notice] = "You need to be trusted to view this page!"
        redirect_to users_url
      end
    end
  end
end
