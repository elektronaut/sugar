# frozen_string_literal: true

module CurrentUserHelper
  def current_user
    @current_user
  end

  def current_user?
    current_user ? true : false
  end
end
