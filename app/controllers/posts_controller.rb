require 'digest/sha1'

class PostsController < ApplicationController

    requires_authentication
    protect_from_forgery :except => [:doodle]

    def load_discussion
        @discussion = Discussion.find(params[:discussion_id]) rescue nil
        unless @discussion
            flash[:notice] = "Can't find that discussion!"
            redirect_to discussions_url and return
        end
    end
    protected     :load_discussion
    before_filter :load_discussion, :except => [:search]

    def load_post
        @post = Post.find(params[:id]) rescue nil
        unless @post
            flash[:notice] = "Can't find that post"
            redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page) and return
        end
    end
    protected     :load_post
    before_filter :load_post, :only => [:show, :edit, :update, :destroy, :quote]
    
    def verify_editable
        unless @post.editable_by?(@current_user)
            flash[:notice] = "You don't have permission to edit that post!"
            redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page) and return
        end
    end
    protected     :verify_editable
    before_filter :verify_editable, :only => [:edit, :update, :destroy]


    def search
        if params[:q]
            redirect_to( { :action => :search, :query => params[:q] } ) and return
        end
        unless @search_query = params[:query]
            flash[:notice] = "No query specified!"
            redirect_to discussions_path and return
        end
        start_time = Time.now
        @posts = Post.search_paginated(:page => params[:page], :trusted => @current_user.trusted?, :query => @search_query)
        @search_time = Time.now - start_time
    end

    def create
        if @discussion.postable_by?(@current_user)
            @post = @discussion.posts.create(:user => @current_user, :body => params[:post][:body])
            if @post.valid?
                @discussion.reload
                flash[:notice] = "Your reply was saved"
                redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page, :anchor => "post-#{@post.id}")
            else
                render :action => :new
            end
        else
            flash[:notice] = "This discussion is closed, you don't have permission to post here"
            redirect_to paged_discussion_url(:id => @discussion, :page => @discussion.last_page)
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
