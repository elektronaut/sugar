class CategoriesController < ApplicationController
    
    requires_authentication
    
    def require_admin
        unless @current_user && @current_user.admin?
            flash[:notice] = "You don't have permission to do that!"
            redirect_to categories_path and return
        end
    end
    protected     :require_admin
    before_filter :require_admin, :except => [:index,:show]

    def load_category
        @category = Category.find(params[:id]) rescue nil
        unless @category
            flash[:notice] = "That's not a valid category!"
            redirect_to categories_path and return
        end
    end
    protected     :load_category
    before_filter :load_category, :only => [:show, :edit, :update, :destroy]

    def index
        @categories = Category.find(:all, :order => :position)
    end

    def show
        @discussions = Discussion.find_paginated(:page => params[:page], :category => @category)
    end
    
    def new
        @category = Category.new
    end
    
    def edit
    end
    
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
