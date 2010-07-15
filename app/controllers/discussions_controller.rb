class DiscussionsController < ApplicationController

	requires_authentication
	requires_user           :except => [:index, :search, :search_posts, :show]
	protect_from_forgery    :except => :mark_as_read
	
	before_filter :load_discussion, :only => [:show, :edit, :update, :destroy, :follow, :unfollow, :favorite, :unfavorite, :search_posts, :mark_as_read]
	before_filter :verify_editable, :only => [:edit, :update, :destroy]
	before_filter :load_categories, :only => [:new, :create, :edit, :update]
	
	protected

		# Loads discussion by params[:id] and checks permissions.
		def load_discussion
			@discussion = Discussion.find(params[:id]) rescue nil
			unless @discussion
				flash[:notice] = "Could not find that discussion!"
				redirect_to discussions_path and return
			end
			unless @discussion.viewable_by?(@current_user)
				flash[:notice] = "You don't have permission to view that discussion!"
				redirect_to discussions_path and return
			end
		end

		# Deflects the request unless the discussion is editable by the logged in user.
		def verify_editable
			unless @discussion.editable_by?(@current_user)
				flash[:notice] = "You don't have permission to edit that discussion!"
				redirect_to discussions_path and return
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
			find_discussion_views
		end

		# Searches discusion titles
		def search
			# Beautify URL
			if params[:q]
				redirect_to(search_with_query_url(:query => params[:q]).gsub(/\.([^\/]*)$/, '%2E\1')) and return
			end
			# Check for missing query
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
				format.html do
					find_discussion_views
					@search_path = search_path
				end
				format.iphone do
					find_discussion_views
					@search_path = search_path
				end
				format.json do
					json = {
						:pages         => @discussions.pages,
						:total_entries => @discussions.total_entries,
						:discussions   => @discussions
					}.to_json(:except => [:delta])
					render :text => json
				end
			end
		end

		# Searches posts within a discussion
		def search_posts
			# Beautify URL
			if params[:q]
				redirect_to({:action => :search_posts, :query => params[:q], :id => @discussion}) and return
			end
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
				:trusted       => (@current_user && @current_user.trusted?)
			)
			@search_path = search_posts_discussion_path(@discussion)
		end

		# Creates a new discussion
		def new
			unless @categories.length > 0
				flash[:notice] = "Can't create a new discussion, no categories have been made!"
				redirect_to categories_url
			end
			@category = @categories.first
			if params[:category_id] && category = Category.find(params[:category_id])
				@category = category
			end
			@discussion = @current_user.discussions.new(:category => @category)
		end

		# Show a discussion
		def show
			context = (request.format == :iphone) ? 0 : 3
			@posts = Post.find_paginated(
				:discussion => @discussion, 
				:page       => params[:page], 
				:context    => context
			)
			# Mark discussion as viewed
			if @current_user
				@current_user.mark_discussion_viewed(@discussion, @posts.last, (@posts.offset + @posts.length))
			end
		end

		# Edit a discussion
		def edit
			@discussion.body = @discussion.posts.first.body
		end

		# Create a new discussion
		def create
			safe_attributes = @current_user.moderator? ? params[:discussion] : Discussion.safe_attributes(params[:discussion])
			@discussion = @current_user.discussions.create(safe_attributes)
			@discussion.update_attributes(safe_attributes.merge(:new_closer => @current_user))
			if @discussion.valid?
				redirect_to discussion_path(@discussion) and return
			else
				flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
				render :action => :new
			end
		end

		# Update a discussion
		def update
			safe_attributes = @current_user.moderator? ? params[:discussion] : Discussion.safe_attributes(params[:discussion])
			@discussion.update_attributes(safe_attributes.merge(:new_closer => @current_user))
			if @discussion.valid?
				flash[:notice] = "Your changes were saved."
				redirect_to discussion_path(@discussion) and return
			else
				flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
				render :action => :edit
			end
		end

		# List discussions marked as favorite
		def favorites
			@section = :favorites
			@discussions = @current_user.favorite_discussions(:page => params[:page], :trusted => @current_user.trusted?)
			find_discussion_views
		end

		# List discussions marked as followed
		def following
			@section = :following
			@discussions = @current_user.following_discussions(:page => params[:page], :trusted => @current_user.trusted?)
			find_discussion_views
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
