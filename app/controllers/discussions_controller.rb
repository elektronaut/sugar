class DiscussionsController < ApplicationController

	requires_authentication
	requires_user           :except => [:index, :search, :search_posts, :show]
	protect_from_forgery    :except => :mark_as_read
	
	before_filter :load_discussion, :only => [:show, :edit, :update, :destroy, :follow, :unfollow, :favorite, :unfavorite, :search_posts, :mark_as_read, :invite_participant]
	before_filter :verify_editable, :only => [:edit, :update, :destroy]
	before_filter :load_categories, :only => [:new, :create, :edit, :update]
	before_filter :set_exchange_params
	
	protected

		# Loads discussion by params[:id] and checks permissions.
		def load_discussion
			begin
				@discussion = Exchange.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				render_error 404 and return
			end
			
			unless @discussion.viewable_by?(@current_user)
				render_error 403 and return
			end
		end

		# Deflects the request unless the discussion is editable by the logged in user.
		def verify_editable
			unless @discussion.editable_by?(@current_user)
				render_error 403 and return
			end
		end
		
		# This is pretty silly and needs rewriting.
		def set_exchange_params
			if params[:conversation]
				params[:exchange] = params[:conversation]
			elsif params[:discussion]
				params[:exchange] = params[:discussion]
			end
		end

		# Loads the categories.
		def load_categories
			@categories = Category.find(:all).reject{|c| c.trusted? unless (@current_user && @current_user.trusted?)}
		end

	public

		# Recent discussions
		def index
			@discussions = Discussion.find_paginated(
				:page    => params[:page], 
				:trusted => (@current_user && @current_user.trusted?)
			)
			load_views_for(@discussions)
		end
		
		# Popular discussions
		def popular
			@days = params[:days].to_i
			#@days = 70 
			unless (1..180).include?(@days)
				redirect_to params.merge({:days => 7}) and return
			end
			@discussions = Discussion.find_popular(
				:page    => params[:page], 
				:trusted => (@current_user && @current_user.trusted?),
				:since   => @days.days.ago
			)
			load_views_for(@discussions)
		end

		# Searches discusion titles
		def search
			# Check for missing query
			params[:query] = params[:q] if params[:q]
			unless @search_query = params[:query]
				flash[:notice] = "No query specified!"
				redirect_to discussions_path and return
			end
			# Search discussions
			@discussions = Discussion.search_paginated(
				:query   => @search_query,
				:page    => params[:page], 
				:trusted => (@current_user && @current_user.trusted?)
			)
			respond_to do |format|
				format.any(:html, :mobile) do
					load_views_for(@discussions)
					@search_path = search_path
				end
				format.json do
					json = {
						:pages         => @discussions.pages,
						:total_entries => @discussions.total_entries,
						# TODO: Fix when Rails bug is fixed
						#:discussions   => @discussions
						:discussions   => @discussions.map{|d| {:discussion => d.attributes}}
					}.to_json(:except => [:delta])
					render :text => json
				end
			end
		end

		# Searches posts within a discussion
		def search_posts
			# Beautify URL
			params[:query] = params[:q] if params[:q]
			# Check for missing query
			unless @search_query = params[:query]
				flash[:notice] = "No query specified!"
				redirect_to discussions_path and return
			end
			# Search posts
			@posts = Post.search_paginated(
				:discussion_id => @discussion.id,
				:page          => params[:page], 
				:query         => @search_query, 
				:trusted       => (@current_user && @current_user.trusted?),
				:conversation  => @discussion.kind_of?(Conversation)
			)
			@search_path = search_posts_discussion_path(@discussion)
		end

		# Creates a new discussion
		def new
			exchange_class = params[:type] == 'conversation' ? Conversation : Discussion
			create_options = {}
			if exchange_class == Discussion
				unless @categories.length > 0
					flash[:notice] = "Can't create a new discussion, no categories have been made!"
					redirect_to categories_url
				end
				@category = @categories.first
				if params[:category_id] && category = Category.find(params[:category_id])
					@category = category
				end
				create_options[:category => @category]
				@discussion = exchange_class.new(:category => @category)
			elsif exchange_class == Conversation
				if params[:username]
					@recipient = User.find_by_username(params[:username])
				end
			end
			@discussion = exchange_class.new(create_options)
		end

		# Show a discussion
		def show
			context = (request.format == :mobile) ? 0 : 3
			@posts = Post.find_paginated(
				:discussion => @discussion, 
				:page       => params[:page], 
				:context    => context
			)
			# Mark discussion as viewed
			if @current_user
				@current_user.mark_discussion_viewed(@discussion, @posts.last, (@posts.offset + @posts.length))
			end
			if @discussion.kind_of?(Conversation)
				@section = :conversations
				ConversationRelationship.find(:first, :conditions => {:conversation_id => @discussion, :user_id => @current_user.id}).update_attribute(:new_posts, false)
				render :template => 'discussions/show_conversation'
			end
		end

		# Edit a discussion
		def edit
			@discussion.body = @discussion.posts.first.body
		end

		# Create a new discussion
		def create
			safe_attributes = @current_user.moderator? ? params[:exchange] : Discussion.safe_attributes(params[:exchange])
			exchange_class = params[:exchange][:type] == 'Conversation' ? Conversation : Discussion

			if params[:recipient_id]
				@recipient = User.find(params[:recipient_id]) rescue nil
			end

			@discussion = exchange_class.create(safe_attributes.merge({:poster_id => @current_user.id}))
			@discussion.update_attributes(safe_attributes.merge(:updated_by => @current_user))

			if @discussion.valid?
				if @discussion.kind_of?(Conversation) && @recipient
					ConversationRelationship.create(:user => @recipient, :conversation => @discussion, :new_posts => true)
				end
				redirect_to discussion_path(@discussion) and return
			else
				flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
				render :action => :new
			end
		end

		# Update a discussion
		def update
			safe_attributes = @current_user.moderator? ? params[:exchange] : Exchange.safe_attributes(params[:exchange])
			@discussion.update_attributes(safe_attributes.merge(:updated_by => @current_user))
			if @discussion.valid?
				flash[:notice] = "Your changes were saved."
				redirect_to discussion_path(@discussion) and return
			else
				flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
				render :action => :edit
			end
		end

		# List discussions marked as favorite
		def conversations
			@section = :conversations
			@discussions = @current_user.paginated_conversations(:page => params[:page])
			load_views_for(@discussions)
		end

		# List discussions marked as favorite
		def favorites
			@section = :favorites
			@discussions = @current_user.favorite_discussions(:page => params[:page], :trusted => @current_user.trusted?)
			load_views_for(@discussions)
		end

		# List discussions marked as followed
		def following
			@section = :following
			@discussions = @current_user.following_discussions(:page => params[:page], :trusted => @current_user.trusted?)
			load_views_for(@discussions)
		end

		# Follow a discussion
		def follow
			DiscussionRelationship.define(@current_user, @discussion, :following => true)
			redirect_to discussion_url(@discussion, :page => params[:page])
		end

		# Unfollow a discussion
		def unfollow
			DiscussionRelationship.define(@current_user, @discussion, :following => false)
			redirect_to discussions_url
		end

		# Favorite a discussion
		def favorite
			DiscussionRelationship.define(@current_user, @discussion, :favorite => true)
			redirect_to discussion_url(@discussion, :page => params[:page])
		end

		# Unfavorite a discussion
		def unfavorite
			DiscussionRelationship.define(@current_user, @discussion, :favorite => false)
			redirect_to discussion_url(@discussion, :page => params[:page])
		end
		
		# Invite a participant
		def invite_participant
			if @discussion.kind_of?(Conversation) && params[:username]
				usernames = params[:username].split(/\s*,\s*/)
				usernames.each do |username|
					if user = User.find_by_username(username)
						ConversationRelationship.create(:conversation => @discussion, :user => user, :new_posts => true)
					end
				end
			end
			if request.xhr?
				render :template => 'discussions/participants', :layout => false
			else
				redirect_to discussion_url(@discussion)
			end
		end

		# Mark discussion as read
		def mark_as_read
			last_index = @discussion.posts_count
			last_post = Post.find(:first, :conditions => {:discussion_id => @discussion.id}, :order => 'created_at DESC')
			@current_user.mark_discussion_viewed(@discussion, last_post, last_index)
			if request.xhr?
				render :layout => false, :text => 'OK'
			end
		end
end
