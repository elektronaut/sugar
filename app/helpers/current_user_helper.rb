# frozen_string_literal: true

module CurrentUserHelper
  def authenticated_session
    @authenticated_session ||= {}.freeze
  end

  def authenticated?
    !authenticated_session.empty?
  end

  def current_user
    return unless authenticated?

    @current_user ||= User.find(authenticated_session[:user_id])
  end

  def current_user?
    current_user ? true : false
  end
end
