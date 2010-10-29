class CategoriesController < ApplicationController

	requires_authentication
	requires_moderator :except => [:index, :show]

	before_filter :load_categories, :only => [:index]
	before_filter :load_category,   :only => [:show, :edit, :update, :destroy]
	before_filter :verify_viewable, :only => [:show, :edit, :update, :destroy]

	protected

		# Loads all categories
		def load_categories
			@categories = Category.find(:all, :order => :position).reject{ |c| !c.viewable_by?(@current_user) }
		end

		# Finds the requested category
		def load_category
			begin
				@category = Category.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				render_error 404 and return
			end
		end
		
		# Verifies that the category is viewable by @current_user
		def verify_viewable
			unless @category.viewable_by?(@current_user)
				flash[:notice] = "You don't have permission to view that category"
				redirect_to categories_path and return unless @category
			end
		end
		
	public

		# GET request on /categories
		def index
			respond_to do |format|
				format.html
				format.iphone
				format.xml    {render :xml  => @categories}
				format.json   {render :json => @categories}
			end
		end

		# GET request on /categories/:id
		def show
			@discussions = Discussion.find_paginated(
				:page     => params[:page], 
				:category => @category, 
				:trusted  => (@current_user && @current_user.trusted?)
			)
			find_discussion_views
		end

		# GET request on /categories/new
		def new
			@category = Category.new
		end

		# GET request on /categories/:id/edit
		def edit
		end

		# POST request on /categories
		def create
			@category = Category.create(params[:category])
			if @category.valid?
				flash[:notice] = "The <em>#{@category.name}</em> category was created!"
				redirect_to categories_path and return
			else
				flash.now[:notice] = "Couldn't save your category, did you fill in all required fields?"
				render :action => :new
			end
		end

		# PUT request on /categories/:id
		def update
			@category.update_attributes(params[:category])
			if @category.valid?
				flash[:notice] = "The <em>#{@category.name}</em> category was saved!"
				redirect_to categories_path and return
			else
				flash.now[:notice] = "Couldn't save your category, did you fill in all required fields?"
				render :action => :edit
			end
		end
		
end