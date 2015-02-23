# encoding: utf-8

module UsersHelper
  def users_tab(name, path, options = {})
    classes = ["tab", options[:class]].compact
    if options[:action] && options[:action] == params[:action]
      classes << "active"
    end
    ("<li class=\"#{classes.join(' ')}\">" + link_to(name, path) + "</li>").
      html_safe
  end
end
