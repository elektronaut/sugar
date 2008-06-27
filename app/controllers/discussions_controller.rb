class DiscussionsController < ApplicationController
    
    requires_authentication
    
    def load_discussion
        @discussion = Discussion.find(params[:id]) rescue nil
        unless @discussion
            flash[:notice] = "Could not find that discussion!"
            redirect_to discussions_path and return
        end
    end
    protected     :load_discussion
    before_filter :load_discussion, :only => [:show, :edit, :update, :destroy]

    def verify_editable
        unless @discussion.editable_by?(@current_user)
            flash[:notice] = "You don't have permission to edit that discussion!"
            redirect_to discussions_path and return
        end
    end
    protected     :verify_editable
    before_filter :verify_editable, :only => [:edit, :update, :destroy]

    def index
        @discussions = Discussion.find_paginated(:page => params[:page])
    end
    
    def new
        @discussion = Discussion.new
    end
    
    def show
        @posts = Post.find_paginated(:page => params[:page], :discussion => @discussion)
    end
    
    def edit
        @discussion.body = @discussion.posts.first.body
    end
    
    def create
        attributes = @current_user.admin? ? params[:discussion] : Discussion.safe_attributes(params[:discussion])
        @discussion = @current_user.discussions.new(attributes)
        if @discussion.valid?
            @discussion.save
            @discussion.create_first_post!
            redirect_to discussion_path(@discussion) and return
        else
            flash.now[:notice] = "Could not save your discussion, did you fill in all required fields?"
            render :action => :new
        end
    end
    
    def update
        attributes = @current_user.admin? ? params[:discussion] : Discussion.safe_attributes(params[:discussion])
        @discussion.update_attributes(attributes)
        if @discussion.valid?
            flash[:notice] = "Your changes were saved."
            redirect_to discussion_path(@discussion) and return
        else
            flash.now[:notice] = "Could not save your discussion, did you fill in all required fields?"
            render :action => :edit
        end
    end
    
end
