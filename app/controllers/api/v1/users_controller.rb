class Api::V1::UsersController < Api::V1::ApiController
  doorkeeper_for :all
  respond_to :json

  def me
    respond_with current_resource_owner
  end

  private

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

end