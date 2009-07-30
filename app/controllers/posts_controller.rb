require 'digest/sha1'

class PostsController < ApplicationController

    requires_authentication :except => [:count]
    protect_from_forgery    :except => [:doodle]

	# Disable sessions and filters for the posts count action, and cache it
	before_filter :authenticate_session,         :except => [:count]
	before_filter :detect_iphone,                :except => [:count]
	before_filter :set_section,                  :except => [:count]
	after_filter  :store_session_authentication, :except => [:count]
	caches_page   :count

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
        last_index = (params[:index].to_i + @posts.length)
        if discussion_view = DiscussionView.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', @current_user.id, @discussion.id])
            discussion_view.update_attributes(:post_index => last_index, :post_id => @posts.last.id) if discussion_view.post_index < last_index
        else
            DiscussionView.create(:discussion_id => @discussion.id, :user_id => @current_user.id, :post_index => last_index, :post_id => @posts.last.id)
        end
		if request.xhr?
			render :layout => false
		end
	end

    def search
        if params[:q]
            redirect_to( { :action => :search, :query => params[:q] } ) and return
        end
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
                flash[:notice] = "Your reply was saved"
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
