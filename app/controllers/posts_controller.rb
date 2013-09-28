# encoding: utf-8

require 'digest/sha1'

class PostsController < ApplicationController

  # Disable sessions and filters for the posts count action, and cache it
  #before_filter :authenticate_session,         :except => [:count]
  #before_filter :detect_mobile,                :except => [:count]
  #before_filter :set_section,                  :except => [:count]
  #after_filter  :store_session_authentication, :except => [:count]
  caches_page   :count

  requires_authentication :except => [:count]
  requires_user           :except => [:count, :since, :search]
  protect_from_forgery    :except => [:doodle]

  # Other filters
  before_filter :load_discussion,              :except => [:search]
  before_filter :verify_viewability,           :except => [:search, :count, :since]
  before_filter :load_post,                    :only => [:show, :edit, :update, :destroy, :quote]
  before_filter :verify_editable,              :only => [:edit, :update, :destroy]
  before_filter :require_and_set_search_query, :only => [:search]
  before_filter :check_postable,               :only => [:create]

  protected

    def load_discussion
      @discussion = Exchange.find(params[:exchange_id]) rescue nil
      unless @discussion
        flash[:notice] = "Can't find that discussion!"
        redirect_to discussions_url and return
      end
    end

    def verify_viewability
      unless @discussion && @discussion.viewable_by?(@current_user)
        flash[:notice] = "You don't have permission to view that discussion!"
        redirect_to discussions_url and return
      end
    end

    def load_post
      @post = Post.find(params[:id]) rescue nil
      unless @post
        flash[:notice] = "Can't find that post"
        redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page) and return
      end
    end

    def verify_editable
      unless @post.editable_by?(@current_user)
        flash[:notice] = "You don't have permission to edit that post!"
        redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page) and return
      end
    end

    def create_doodle(encoded_data)
      data = Base64.decode64(encoded_data)
      hash = Digest::SHA1.hexdigest(data)
      doodle_file = Rails.root.join("public/doodles/#{hash}.jpg")
      File.open(doodle_file, 'wb') do |fh|
        fh.write data
      end
      hash
    end

    def search_query
      params[:query] || params[:q]
    end

    def require_and_set_search_query
      unless @search_query = search_query
        flash[:notice] = "No query specified!"
        redirect_to discussions_path and return
      end
    end

    def check_postable
      unless @discussion.postable_by?(@current_user)
        flash[:notice] = "This discussion is closed, you don't have permission to post here"
        redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page)
      end
    end

  public

    def count
      @count = @discussion.posts_count
      respond_to do |format|
        format.json do
          render :json => {:posts_count => @count}.to_json
        end
      end
    end

    def since
      @posts = @discussion.posts.limit(200).offset(params[:index]).for_view
      if @current_user
        @current_user.mark_discussion_viewed(@discussion, @posts.last, (params[:index].to_i + @posts.length))
      end
      if @discussion.kind_of?(Conversation)
        @current_user.conversation_relationships.where(:conversation_id => @discussion.id).first.update_attributes(new_posts: false)
      end
      if request.xhr?
        render :layout => false
      end
    end

    def search
      @search_path = search_posts_path
      @posts = Post.search_results(search_query, user: @current_user, page: params[:page])
    end

    def create
      @post = @discussion.posts.create(:user => @current_user, :body => params[:post][:body])
      if @post.valid?
        @discussion.reload
        # if @post.mentions_users?
        # 	@post.mentioned_users.each do |mentioned_user|
        # 		logger.info "Mentions: #{mentioned_user.username}"
        # 	end
        # end
        if request.xhr?
          render :status => 201, :text => 'Created'
        else
          redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page, :anchor => "post-#{@post.id}")
        end
      else
        if request.xhr?
          render :status => 400, :text => 'Invalid post'
        else
          render :action => :new
        end
      end
    end

    def preview
      @post = @discussion.posts.new(body: params[:post][:body])
      @post.user = @current_user
      if request.xhr?
        render :layout => false
      end
    end

    def doodle
      if @discussion.postable_by?(@current_user)
        hash = create_doodle(params[:drawing])
        @post = @discussion.posts.create(
          :user => @current_user,
          :body => '<div class="drawing"><img src="/doodles/' + hash + '.jpg" alt="doodle" /></div>'
        )
        render :text => paged_discussion_url(:id => @discussion, :page => @discussion.last_page, :anchor => "post-#{@post.id}"), :layout => false
      else
        render :text => paged_discussion_url(:id => @discussion, :page => @discussion.last_page), :layout => false
      end
    end

    def edit
      if request.xhr?
        render :layout => false
      end
    end

    def quote
      render :layout => false
    end

    def update
      attributes = {
        :body      => params[:post][:body],
        :edited_at => Time.now
      }
      if @post.update_attributes(attributes)
        redirect_to paged_discussion_url(:id => @discussion, :page => @post.page, :anchor => "post-#{@post.id}")
      else
        flash.now[:notice] = "Could not save your post."
        render :action => :edit
      end
    end

end
