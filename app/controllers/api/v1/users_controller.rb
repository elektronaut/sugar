class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :all
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

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "not-found" }.to_json, status: 404 and return
  end

end