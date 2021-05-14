# frozen_string_literal: true

require "digest/md5"

class ApplicationController < ActionController::Base
  include Authentication
  include ExchangeResponder
  include ViewedTrackerHelper

  layout "application"

  protect_from_forgery with: :exception

  before_action :disable_xss_protection
  before_action :load_configuration
  before_action :set_time_zone
  before_action :detect_mobile
  before_action :set_section
  before_action :set_theme
  before_action :set_sentry_context

  protected

  def current_user_context
    return {} unless current_user?

    { id: current_user.id, username: current_user.username }
  end

  def disable_xss_protection
    # Disabling this is probably not a good idea, but the header
    # causes Chrome to choke when being redirected back after a submit
    # and the page contains an iframe.
    response.headers["X-XSS-Protection"] = "0"
  end

  def error_messages
    { 404 => "Not found" }
  end

  def paginated_json_path(page)
    page && url_for(page: page, only_path: true, format: :json)
  end

  # Renders an error
  def render_error(error, options = {})
    options[:status] ||= error if error.is_a?(Numeric)
    respond_to do |format|
      format.any(:html, :mobile) { options[:template] ||= "errors/#{error}" }
      format.any(:xml, :json) { options[:text] ||= error_messages[error] }
    end
    render options
  end

  def load_configuration
    Sugar.config.load
  end

  def set_time_zone
    Time.zone = current_user.time_zone if current_user.try(&:time_zone)
  end

  def mobile_user_agent?
    request.host =~ /^(iphone|m|mobile)\./ ||
      (request.env["HTTP_USER_AGENT"] &&
      request.env["HTTP_USER_AGENT"][%r{(Mobile/.+Safari|Android|IEMobile)}])
  end
  helper_method :mobile_user_agent?

  def detect_mobile
    return unless mobile_user_agent?

    session[:mobile_format] = params[:mobile_format] ||
                              session[:mobile_format] ||
                              "mobile"
    return unless session[:mobile_format] == "mobile" &&
                  request.format == "text/html"

    request.format = :mobile
  end

  def require_s3
    return if Sugar.aws_s3?

    flash[:notice] = "Amazon Web Services not configured!"
    redirect_to root_url
  end

  def set_sentry_context
    Sentry.set_user(current_user_context)
    Sentry.set_extras(params: params.to_unsafe_h)
  end

  def set_section
    mapping = {
      UsersController => :users,
      InvitesController => :invites,
      ConversationsController => :conversations
    }
    mapping[self.class] || :discussions
  end

  def mobile_theme
    if current_user?
      Theme.find(current_user.mobile_theme)
    else
      Theme.find(Sugar.config.default_mobile_theme)
    end
  end

  def theme
    if current_user?
      Theme.find(current_user.theme)
    else
      Theme.find(Sugar.config.default_theme)
    end
  end

  def set_theme
    respond_to do |format|
      format.mobile do
        @theme = mobile_theme
      end
      format.any do
        @theme = theme
      end
    end
  end
end
