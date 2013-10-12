# encoding: utf-8

module ApplicationHelper
  include AvatarsHelper
  include ExchangesHelper
  include LayoutHelper
  include PaginationHelper
  include PostsHelper

  def facebook_oauth_url(redirect_uri)
    "https://www.facebook.com/dialog/oauth?client_id=#{Sugar.config(:facebook_app_id)}&redirect_uri=#{redirect_uri}&scope=email"
  end

  def pretty_link(url)
    url = "http://"+url unless url =~ /^(f|ht)tps?:\/\//
    url = url.gsub(/\/$/, '') if url =~ /^(f|ht)tps?:\/\/[\w\d\-\.]*\/$/
    link_to url.gsub(/^(f|ht)tps?:\/\//, ''), url
  end

  # Generate HTML for a field, with label and optionally description and errors.
  #
  # The options are:
  # * <tt>:description</tt>: Description of the field
  # * <tt>:errors</tt>:      Error messages for the attribute
  #
  # An example:
  #   <% form_for 'user', @user do |f| %>
  #     <%= labelled_field f.text_field( :username ), "Username",
  #                        description: "Choose your username, minimum 4 characters",
  #                        errors: @user.errors[:username] %>
  #     <%= submit_tag "Save" %>
  #   <% end %>
  #
  def labelled_field(field, label=nil, options={}, &block)
    if !options[:errors].blank?
      output  = '<p class="field field_with_errors">'
    else
      output  = '<p class="field">'
    end
    output += "<label>#{label}" if label
    if options[:errors]
      error = options[:errors]
      error = error.last if error.kind_of? Array
      output += ' <span class="error">' + error.to_s + '</span>'
    end
    output += "<span class=\"description\"> &mdash; #{options[:description]}</span>" if options[:description]
    output += "</label>" if label
    output += field
    output += "<br />"+capture(&block) if block_given?
    output += "</p>"
    return output.html_safe
  end

  def possessive(noun)
    (noun =~ /s$/) ? "#{noun}'" : "#{noun}'s"
  end

  # Generates a link to the users profile
  def profile_link(user, link_text=nil, options={})
    if user
      link_text ||= user.username
      link_to link_text, user_profile_path(id: user.username), {title: "#{possessive(user.username)} profile"}.merge(options)
    else
      "Unknown"
    end
  end

end
