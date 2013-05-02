# encoding: utf-8

class CategoriesController < ApplicationController

  requires_authentication
  requires_moderator :except => [:index, :show]

  respond_to :html, :mobile, :xml, :json

  before_filter :load_categories, :only => [:index]
  before_filter :load_category,   :only => [:show, :edit, :update, :destroy]
  before_filter :verify_viewable, :only => [:show, :edit, :update, :destroy]

  # GET on /categories
  def index
    respond_with(@categories)
  end

  # GET on /categories/:id
  def show
    respond_with(@category) do |format|
      format.any(:html, :mobile) do
        @discussions = @category.discussions.viewable_by(@current_user).page(params[:page]).for_view
        load_views_for(@discussions)
      end
    end
  end

  # GET on /categories/new
  def new
    respond_with(@category = Category.new)
  end

  # GET on /categories/:id/edit
  def edit
    respond_with(@category)
  end

  # POST on /categories
  def create
    @category = Category.new(params[:category])
    respond_with(@category) do |format|
      if @category.save
        format.any(:html, :mobile) { successful_update("The <em>#{@category.name}</em> category was created") }
      else
        flash.now[:notice] = "Couldn't save your category, did you fill in all required fields?"
        format.any(:html, :mobile) { render :action => :new }
      end
    end
  end

  # PUT on /categories/:id
  def update
    respond_with(@category) do |format|
      if @category.update_attributes(params[:category])
        format.any(:html, :mobile) { successful_update("The <em>#{@category.name}</em> category was saved") }
      else
        flash.now[:notice] = "Couldn't save your category, did you fill in all required fields?"
        format.any(:html, :mobile) { render :action => :edit }
      end
    end
  end

  private

  def successful_update(message)
    flash[:notice] = message
    redirect_to categories_url and return
  end

  # Loads all categories
  def load_categories
    @categories = Category.viewable_by(@current_user)
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
      render_error 403 and return
    end
  end

end
