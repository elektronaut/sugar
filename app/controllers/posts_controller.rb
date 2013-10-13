# encoding: utf-8

require 'digest/sha1'

class PostsController < ApplicationController

  # Disable sessions and filters for the posts count action, and cache it
  #before_filter :authenticate_session,         except: [:count]
  #before_filter :detect_mobile,                except: [:count]
  #before_filter :set_section,                  except: [:count]
  #after_filter  :store_session_authentication, except: [:count]
  caches_page   :count

  requires_authentication except: [:count]
  requires_user           except: [:count, :since, :search]
  protect_from_forgery    except: [:drawing]

  # Other filters
  before_filter :load_discussion,              except: [:search]
  before_filter :verify_viewability,           except: [:search, :count, :since]
  before_filter :load_post,                    only: [:show, :edit, :update, :destroy, :quote]
  before_filter :verify_editable,              only: [:edit, :update, :destroy]
  before_filter :require_and_set_search_query, only: [:search]
  before_filter :check_postable,               only: [:create]
  before_filter :require_s3,                   only: [:drawing]

  protected

    def load_discussion
      @exchange = Exchange.find(params[:discussion_id]) rescue nil
      unless @exchange
        flash[:notice] = "Can't find that discussion!"
        redirect_to discussions_url and return
      end
    end

    def verify_viewability
      unless @exchange && @exchange.viewable_by?(current_user)
        flash[:notice] = "You don't have permission to view that discussion!"
        redirect_to discussions_url and return
      end
    end

    def load_post
      @post = Post.find(params[:id]) rescue nil
      unless @post
        flash[:notice] = "Can't find that post"
        redirect_to paged_discussion_url(id: @exchange, page: @exchange.last_page) and return
      end
    end

    def verify_editable
      unless @post.editable_by?(current_user)
        flash[:notice] = "You don't have permission to edit that post!"
        redirect_to paged_discussion_url(id: @exchange, page: @exchange.last_page) and return
      end
    end

    def search_query
      params[:query] || params[:q]
    end

    def require_and_set_search_query
      unless @search_query = search_query
        flash[:notice] = "No query specified!"
        redirect_to discussions_path and return
      end
    end

    def check_postable
      unless @exchange.postable_by?(current_user)
        flash[:notice] = "This discussion is closed, you don't have permission to post here"
        redirect_to paged_discussion_url(id: @exchange, page: @exchange.last_page)
      end
    end

  public

    def count
      @count = @exchange.posts_count
      respond_to do |format|
        format.json do
          render json: {posts_count: @count}.to_json
        end
      end
    end

    def since
      @posts = @exchange.posts.limit(200).offset(params[:index]).for_view
      if current_user?
        current_user.mark_discussion_viewed(@exchange, @posts.last, (params[:index].to_i + @posts.length))
      end
      if @exchange.kind_of?(Conversation)
        current_user.conversation_relationships.where(conversation_id: @exchange.id).first.update_attributes(new_posts: false)
      end
      if request.xhr?
        render layout: false
      end
    end

    def search
      @search_path = search_posts_path
      @posts = Post.search_results(search_query, user: current_user, page: params[:page])
    end

    def create
      attributes = {
        user: current_user,
        body: params[:post][:body]
      }
      attributes[:format] = params[:post][:format] if params[:post][:format]
      @post = @exchange.posts.create(attributes)
      if @post.valid?
        @exchange.reload
        # if @post.mentions_users?
        # 	@post.mentioned_users.each do |mentioned_user|
        # 		logger.info "Mentions: #{mentioned_user.username}"
        # 	end
        # end
        if request.xhr?
          render status: 201, text: 'Created'
        else
          redirect_to paged_discussion_url(id: @exchange, page: @exchange.last_page, anchor: "post-#{@post.id}")
        end
      else
        if request.xhr?
          render status: 400, text: 'Invalid post'
        else
          render action: :new
        end
      end
    end

    def preview
      @post = @exchange.posts.new(body: params[:post][:body], format: params[:post][:format])
      @post.user = current_user
      if request.xhr?
        render layout: false
      end
    end

    def drawing
      if @exchange.postable_by?(current_user)
        Tempfile.open("drawing.jpg", encoding: "ascii-8bit") do |file|
          data = Base64.decode64(params[:drawing])
          file.write(data)
          file.rewind
          upload = Upload.new(file, name: "drawing.jpg")
          if upload.valid?
            upload.save
            @post = @exchange.posts.create(
              user: current_user,
              body: "<div class=\"drawing\"><img src=\"#{upload.url}\" alt=\"Drawing\" /></div>"
            )
          end
        end
      end

      if @post
        render text: paged_discussion_url(id: @exchange, page: @exchange.last_page, anchor: "post-#{@post.id}"), layout: false
      else
        render text: paged_discussion_url(id: @exchange, page: @exchange.last_page), layout: false
      end
    end

    def edit
      if request.xhr?
        render layout: false
      end
    end

    def quote
      render layout: false
    end

    def update
      attributes = {
        body:      params[:post][:body],
        edited_at: Time.now
      }
      attributes[:format] = params[:post][:format] if params[:post][:format]
      if @post.update_attributes(attributes)
        redirect_to paged_discussion_url(id: @exchange, page: @post.page, anchor: "post-#{@post.id}")
      else
        flash.now[:notice] = "Could not save your post."
        render action: :edit
      end
    end

end
