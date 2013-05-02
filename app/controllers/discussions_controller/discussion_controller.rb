class DiscussionsController < ApplicationController
  module DiscussionController
    extend ActiveSupport::Concern

    included do
      before_filter :load_categories,    :only => [:new, :create, :edit, :update]
      before_filter :require_categories, :only => [:new, :create]
    end

    # Recent discussions
    def index
      @discussions = Discussion.viewable_by(@current_user).page(params[:page]).for_view
      load_views_for(@discussions)
    end

    # Popular discussions
    def popular
      @days = params[:days].to_i
      unless (1..180).include?(@days)
        redirect_to params.merge({:days => 7}) and return
      end
      @discussions = Discussion.viewable_by(@current_user).popular_in_the_last(@days.days).page(params[:page])
      load_views_for(@discussions)
    end

    # Searches discusion titles
    def search
      @discussions = Discussion.search_results(search_query, user: @current_user, page: params[:page])

      respond_to do |format|
        format.any(:html, :mobile) do
          load_views_for(@discussions)
          @search_path = search_path
        end
        format.json do
          json = {
            :pages         => @discussions.pages,
            :total_entries => @discussions.total,
            # TODO: Fix when Rails bug is fixed
            #:discussions   => @discussions
            :discussions   => @discussions.map{|d| {:discussion => d.attributes}}
          }.to_json(:except => [:delta])
          render :text => json
        end
      end
    end

    # List discussions marked as favorite
    def favorites
      @section = :favorites
      @discussions = @current_user.favorite_discussions.viewable_by(@current_user).page(params[:page]).for_view
      load_views_for(@discussions)
    end

    # List discussions marked as followed
    def following
      @section = :following
      @discussions = @current_user.followed_discussions.viewable_by(@current_user).page(params[:page]).for_view
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

    # Mark discussion as read
    def mark_as_read
      last_index = @discussion.posts_count
      last_post = Post.find(:first, :conditions => {:discussion_id => @discussion.id}, :order => 'created_at DESC')
      @current_user.mark_discussion_viewed(@discussion, last_post, last_index)
      if request.xhr?
        render :layout => false, :text => 'OK'
      end
    end

    private

    def load_categories
      @categories = Category.viewable_by(@current_user)
    end

    def require_categories
      if @categories.length == 0 && exchange_class == Discussion
        flash[:notice] = "Can't create a new discussion, no categories have been made!"
        redirect_to categories_url and return
      end
    end

  end
end