require 'digest/sha1'

class PostsController < ApplicationController

	# Disable sessions and filters for the posts count action, and cache it
	before_filter :authenticate_session,         :except => [:count]
	before_filter :detect_mobile,                :except => [:count]
	before_filter :set_section,                  :except => [:count]
	after_filter  :store_session_authentication, :except => [:count]
	caches_page   :count

	requires_authentication :except => [:count]
	requires_user           :except => [:count, :since, :search]
	protect_from_forgery    :except => [:doodle]

	# Other filters
	before_filter :load_discussion,    :except => [:search]
	before_filter :verify_viewability, :except => [:search, :count]
	before_filter :load_post,       :only => [:show, :edit, :update, :destroy, :quote]
	before_filter :verify_editable, :only => [:edit, :update, :destroy]

	protected

		def load_discussion
			@discussion = Exchange.find(params[:discussion_id]) rescue nil
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

	public

		def count
			@count = @discussion.posts_count
			respond_to do |format|
				format.js do 
					render :text => {:posts_count => @count}.to_json
				end
			end
		end

		def since
			unless @discussion.viewable_by?(@current_user)
				render :text => '', :status => 403 and return
			end
			@posts = @discussion.posts_since_index(params[:index])
			if @current_user
				@current_user.mark_discussion_viewed(@discussion, @posts.last, (params[:index].to_i + @posts.length))
			end
			if @discussion.kind_of?(Conversation)
				ConversationRelationship.find(:first, :conditions => {:conversation_id => @discussion, :user_id => @current_user.id}).update_attribute(:new_posts, false)
			end
			if request.xhr?
				render :layout => false
			end
		end

		def search
			params[:query] = params[:q] if params[:q]
			unless @search_query = params[:query]
				flash[:notice] = "No query specified!"
				redirect_to discussions_path and return
			end
			@posts = Post.search_paginated(:page => params[:page], :trusted => @current_user.trusted?, :query => @search_query)
			@search_path = search_posts_path
		end

		def create
			if @discussion.postable_by?(@current_user)
				@post = @discussion.posts.create(:user => @current_user, :body => params[:post][:body])
				if @post.valid?
					@discussion.reload
					@discussion.fix_counter_cache!
					if @discussion.kind_of?(Conversation)
						@discussion.conversation_relationships.reject{|r| r.user == @current_user}.each{|r| r.update_attribute(:new_posts, true)}
					end
					# if @post.mentions_users?
					# 	@post.mentioned_users.each do |mentioned_user|
					# 		logger.info "Mentions: #{mentioned_user.username}"
					# 	end
					# end
					if request.xhr?
						render :status => 201, :text => 'Created'
					else
						flash[:notice] = "Your reply was saved"
						redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page, :anchor => "post-#{@post.id}")
					end
				else
					if request.xhr?
						render :status => 400, :text => 'Invalid post'
					else
						render :action => :new
					end
				end
			else
				flash[:notice] = "This discussion is closed, you don't have permission to post here"
				redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page)
			end
		end
		
		def preview
			@post = @discussion.posts.new(params[:post])
			@post.user = @current_user
			if request.xhr?
				render :layout => false
			end
		end

		def doodle
			if @discussion.postable_by?(@current_user)
				doodle_hash = Digest::SHA1.hexdigest(Time.now.to_s + @current_user.username)
				doodle_data = Base64.decode64(params[:drawing])
				doodle_file = File.join(File.dirname(__FILE__), '../../public/doodles/'+doodle_hash+'.jpg')
				File.open(doodle_file, 'wb'){ |fh| fh.write doodle_data }
				@post = @discussion.posts.create(:user => @current_user, :body => '<div class="drawing"><img src="/doodles/'+doodle_hash+'.jpg" alt="doodle" /></div>')
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
			if params[:post] && params[:post][:body]
				# No reason to update anything else, should be more secure
				@post.update_attribute(:body, params[:post][:body])
				@post.update_attribute(:edited_at, Time.now)
			end
			if @post.valid?
				flash[:notice] = "Your changes were saved"
				redirect_to paged_discussion_url(:id => @discussion, :page => @post.page, :anchor => "post-#{@post.id}")
			else
				flash.now[:notice] = "Couldn't save your post. Did you fill in a body?"
				render :action => :edit
			end
		end

end
