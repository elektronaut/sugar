class PostsController < ApplicationController

    def load_discussion
        @discussion = Discussion.find(params[:discussion_id]) rescue nil
        unless @discussion
            flash[:notice] = "Can't find that discussion!"
            redirect_to discussions_url and return
        end
    end
    protected     :load_discussion
    before_filter :load_discussion
    
    def create
        @post = @discussion.posts.create(params[:post].merge({:user => @current_user}))
        flash[:notice] = "Your reply was saved"
        redirect_to url_for(:controller => 'discussions', :action => 'show', :id => @discussion, :page => @discussion.last_page, :anchor => "post-#{@post.id}")
    end

end
