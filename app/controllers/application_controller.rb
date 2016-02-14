# encoding: utf-8

require "digest/md5"

class ApplicationController < ActionController::Base
  include Authentication
  include ViewedTrackerHelper

  self.responder = Sugar::Responder

  layout "application"

  protect_from_forgery

  before_action :disable_xss_protection
  before_action :load_configuration
  before_action :set_time_zone
  before_action :detect_mobile
  before_action :set_section
  before_action :set_theme

  protected

  def disable_xss_protection
    # Disabling this is probably not a good idea, but the header
    # causes Chrome to choke when being redirected back after a submit
    # and the page contains an iframe.
    response.headers["X-XSS-Protection"] = "0"
  end

  def error_messages
    {
      404 => "Not found"
    }
  end

  # Renders an error
  def render_error(error, options = {})
    if error.is_a?(Numeric)
      options[:status] ||= error
    end
    respond_to do |format|
      format.html { options[:template] ||= "errors/#{error}" }
      format.mobile { options[:template] ||= "errors/#{error}" }
      format.xml { options[:text] ||= error_messages[error] }
      format.json { options[:text] ||= error_messages[error] }
    end
    render options
  end

  def respond_with_exchanges(exchanges)
    viewed_tracker.exchanges = exchanges
    respond_with(exchanges)
  end

  def load_configuration
    Sugar.config.load
  end

  def set_time_zone
    if current_user.try(&:time_zone)
      Time.zone = current_user.time_zone
    end
  end

  def mobile_user_agent?
    request.host =~ /^(iphone|m|mobile)\./ ||
      (request.env["HTTP_USER_AGENT"] &&
      request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari|Android|IEMobile)/])
  end
  helper_method :mobile_user_agent?

  def detect_mobile
    if mobile_user_agent?
      session[:mobile_format] ||= "mobile"
      session[:mobile_format] = params[:mobile_format] if params[:mobile_format]
      if session[:mobile_format] == "mobile" && request.format == "text/html"
        request.format = :mobile
      end
    end
  end

  def require_s3
    unless Sugar.aws_s3?
      flash[:notice] = "Amazon Web Services not configured!"
      redirect_to root_url
      return
    end
  end

  def set_section
    case self.class.to_s
    when "UsersController"
      @section = :users
    when "MessagesController"
      @section = :messages
    when "InvitesController"
      @section = :invites
    when "ConversationsController"
      @section = :conversations
    else
      @section = :discussions
    end
  end

  def get_mobile_theme
    if current_user?
      Theme.find(current_user.mobile_theme)
    else
      Theme.find(Sugar.config.default_mobile_theme)
    end
  end

  def get_theme
    if current_user?
      Theme.find(current_user.theme)
    else
      Theme.find(Sugar.config.default_theme)
    end
  end

  def set_theme
    respond_to do |format|
      format.mobile do
        @theme = get_mobile_theme
      end
      format.any do
        @theme = get_theme
      end
    end
  end
end
