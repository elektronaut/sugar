# encoding: utf-8

require 'digest/md5'

class ApplicationController < ActionController::Base

  include Authentication

  layout 'application'

  protect_from_forgery

  before_filter :load_configuration
  before_filter :set_time_zone
  before_filter :detect_mobile
  before_filter :set_section
  before_filter :set_theme

  protected

    # Renders an error
    def render_error(error, options={})
      options[:status] ||= error if error.kind_of?(Numeric)
      error_messages = {
        404 => 'Not found'
      }
      respond_to do |format|
        format.html   {options[:template] ||= "errors/#{error}"}
        format.mobile {options[:template] ||= "errors/#{error}"}
        format.xml    {options[:text] ||= error_messages[error]}
        format.json   {options[:text] ||= error_messages[error]}
      end
      render options
    end

    # Finds DiscussionViews for the given discussion.
    def load_views_for(discussions)
      if @current_user && discussions && discussions.length > 0
        @discussion_views = DiscussionView.where(user_id: @current_user.id, discussion_id: discussions.map(&:id).uniq)
      end
    end

    # Load configuration
    def load_configuration
      Sugar.load_config!
    end

    # Set time zone for user
    def set_time_zone
      if @current_user && @current_user.time_zone
        Time.zone = @current_user.time_zone
      end
    end

    # Detects the mobile user agent string and sets request.format = :mobile
    def detect_mobile
      @mobile_user_agent = false
      @mobile_user_agent ||= request.host =~ /^(iphone|m|mobile)\./
      @mobile_user_agent ||= request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari|Android|IEMobile)/]
      if @mobile_user_agent
        session[:mobile_format] ||= 'mobile'
        session[:mobile_format] = params[:mobile_format] if params[:mobile_format]
        request.format = :mobile if session[:mobile_format] == 'mobile'
      end
    end

    # Sets @section to the current section.
    def set_section
      case self.class.to_s
      when 'UsersController'
        @section = :users
      when 'MessagesController'
        @section = :messages
      when 'InvitesController'
        @section = :invites
      else
        @section = :discussions
      end
    end

    def set_theme
      respond_to do |format|
        format.mobile do
          if @current_user
            @theme = Theme.find(@current_user.mobile_theme)
          else
            @theme = Theme.find(Sugar.config(:default_mobile_theme))
          end
        end
        format.any do
          if @current_user
            @theme = Theme.find(@current_user.theme)
          else
            @theme = Theme.find(Sugar.config(:default_theme))
          end
        end
      end
    end

end
