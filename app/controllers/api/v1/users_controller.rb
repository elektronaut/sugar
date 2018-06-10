# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApiController
      before_action :doorkeeper_authorize!
      respond_to :json
      before_action :find_user, only: [:show]

      def me
        respond_with current_resource_owner
      end

      def index
        @users = User.active
        respond_with @users
      end

      def banned
        @users = User.banned
        respond_with @users
      end

      def show
        respond_with @user
      end

      private

      def find_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "not-found" }.to_json, status: :not_found
        nil
      end
    end
  end
end
