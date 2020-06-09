# frozen_string_literal: true

module UsersHelper
  def status_options
    User.statuses.keys.map do |status|
      [t("user.status.#{status}"), status]
    end
  end

  def users_tab(name, path, options = {})
    classes = ["tab", options[:class]].compact
    classes << "active" if options[:action] && options[:action] == params[:action]
    content_tag(:li, link_to(name, path), class: classes.join(" "))
  end
end
