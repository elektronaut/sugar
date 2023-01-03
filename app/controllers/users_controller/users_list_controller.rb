# frozen_string_literal: true

class UsersController < ApplicationController
  module UsersListController
    extend ActiveSupport::Concern

    def index
      @users = User.active_and_memorialized.by_username
      respond_to do |format|
        format.html
        format.html.mobile { @online_users = @users.select(&:online?) }
        format.json { render json: UserResource.new(@users) }
      end
    end

    def deactivated
      @users = User.deactivated.by_username
      respond_with_users(@users)
    end

    def recently_joined
      @users = User.recently_joined.limit(25)
      respond_with_users(@users)
    end

    def online
      @users = User.online.by_username
      respond_with_users(@users)
    end

    def admins
      @users = User.admins.by_username
      respond_with_users(@users)
    end

    def top_posters
      @users = User.top_posters.limit(50)
      respond_with_users(@users)
    end

    private

    def serialize_users(users); end

    def respond_with_users(users)
      respond_to do |format|
        format.html
        format.json { render json: UserResource.new(users) }
      end
    end
  end
end
