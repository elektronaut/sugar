# encoding: utf-8

module CurrentUserHelper
  def current_user
    @current_user
  end

  def current_user?
    current_user ? true : false
  end
end
