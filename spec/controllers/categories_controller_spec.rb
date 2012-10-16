# encoding: utf-8

require 'spec_helper'

describe CategoriesController, :rspec => true do
  describe 'with public browsing off' do
    before { Sugar.config(:public_browsing, false); Sugar.save_config! }
    it_requires_login_for :new, :edit, :create, :update
  end

  before do
    @category = create(:category)
    @trusted_category = create(:trusted_category)
  end

  describe 'logged in as regular user' do
    before { login }

    describe 'GET index' do
      before { get :index }
      it { should assign_to(:categories).with_kind_of(Enumerable) }
      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should_not set_the_flash }
      it 'finds the regular categories' do
        assigns(:categories).should include(@category)
      end
      it 'does not find trusted categories' do
        assigns(:categories).should_not include(@trusted_category)
      end
    end

    describe 'GET show' do
      before { get :show, :id => @category }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should assign_to(:discussions).with_kind_of(Pagination::InstanceMethods) }
      it { should respond_with(:success) }
      it { should render_template(:show) }
      it { should_not set_the_flash }
    end
  end

  describe 'logged in as a trusted user' do
    before { login(@user = create(:trusted_user)) }
    describe 'GET index' do
      before { get :index }
      it 'finds the regular categories' do
        assigns(:categories).should include(@category)
      end
      it 'finds the trusted categories' do
        assigns(:categories).should include(@trusted_category)
      end
    end
  end

  describe 'logged in as moderator' do
    before { login(@user = create(:moderator)) }

    describe 'GET new' do
      before { get :new }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should respond_with(:success) }
      it { should render_template(:new) }
      it { should_not set_the_flash }
    end

    describe 'GET edit' do
      before { get :edit, :id => @category }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
      it { should_not set_the_flash }
    end

    describe 'POST create' do
      describe 'with valid params' do
        before { post :create, :category => {:name => 'Stuff'} }
        it { should assign_to(:category).with_kind_of(Category) }
        it { should set_the_flash.to(/The (.*) category was created/) }
        it 'redirects back to categories' do
          response.should redirect_to(categories_url)
        end
      end
      describe 'without valid params' do
        before { post :create, :category => {} }
        it { should assign_to(:category).with_kind_of(Category) }
        it { should set_the_flash.now.to(/Couldn't save your category/) }
        it { should respond_with(:success) }
        it { should render_template(:new) }
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        before { put :update, :id => @category, :category => {:name => 'Stuff'} }
        it { should assign_to(:category).with_kind_of(Category) }
        it { should set_the_flash.to(/The (.*) category was saved/) }
        it 'redirects back to categories' do
          response.should redirect_to(categories_url)
        end
        it 'changes the name of the category' do
          assigns(:category).name.should eq('Stuff')
        end
      end
      describe 'without valid params' do
        before { put :update, :id => @category, :category => {:name => ''} }
        it { should assign_to(:category).with_kind_of(Category) }
        it { should set_the_flash.now.to(/Couldn't save your category/) }
        it { should respond_with(:success) }
        it { should render_template(:edit) }
      end
    end

  end
end
