# frozen_string_literal: true

class UserLinksController < ApplicationController
  requires_authentication
  before_action :require_type_param, only: %i[index]

  def all
    @labels = UserLink.labels
  end

  def index
    @label = params[:type]
    @users = User.active_and_memorialized.by_username
                 .joins(:user_links)
                 .where(user_links: { label: @label })
                 .group("users.id")
  end

  private

  def require_type_param
    return if params[:type]

    redirect_to all_user_links_url
  end
end
