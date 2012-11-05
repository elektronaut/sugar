# encoding: utf-8

require 'spec_helper'

describe CategoriesController do

  let(:category)  { create(:category) }
  let(:user)      { create(:user) }
  let(:moderator) { create(:moderator) }

  it_requires_authentication_for :index, :show, :new, :edit, :create, :update
  it_requires_moderator_for :new, :edit, :create, :update

  describe "#load_categories" do

    let!(:category) { create(:category) }
    let!(:trusted_category) { create(:trusted_category) }

    before { login(user); get :index }

    context "when user isn't trusted" do
      let(:user) { create(:user) }
      specify { assigns(:categories).should include(category) }
      specify { assigns(:categories).should_not include(trusted_category) }
    end

    context "when user is trusted" do
      let(:user) { create(:trusted_user) }
      specify { assigns(:categories).should include(category) }
      specify { assigns(:categories).should include(trusted_category) }
    end

  end

  describe "#load_category" do

    before { login; get :show, id: category_id }

    context "when category exists" do
      let(:category_id) { category.id }
      it { should assign_to(:category).with_kind_of(Category) }
    end

    context "when category doesn't exist" do
      let(:category_id) { 1231241 }
      it { should_not assign_to(:category) }
      it { should respond_with(404) }
    end

  end

  describe "verify_viewable" do

    before { login; get :show, id: category }

    context "when category isn't viewable" do
      let(:category) { create(:trusted_category) }
      it { should respond_with(403) }
    end

    context "when category is viewable" do
      it { should_not respond_with(403) }
    end

  end

  describe "GET index" do
    before { login; get :index }
    it { should assign_to(:categories).with_kind_of(Enumerable) }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
  end

  describe "GET show" do
    before { login; get :show, :id => category }
    it { should assign_to(:category).with_kind_of(Category) }
    it { should assign_to(:discussions).with_kind_of(Pagination::InstanceMethods) }
    it { should respond_with(:success) }
    it { should render_template(:show) }
    it { should_not set_the_flash }
  end

  describe "GET new" do
    before { login(moderator); get :new }
    it { should assign_to(:category).with_kind_of(Category) }
    it { should respond_with(:success) }
    it { should render_template(:new) }
    it { should_not set_the_flash }
  end

  describe "GET edit" do
    before { login(moderator); get :edit, id: category }
    it { should assign_to(:category).with_kind_of(Category) }
    it { should respond_with(:success) }
    it { should render_template(:edit) }
    it { should_not set_the_flash }
  end

  describe "POST create" do

    before { login(moderator) }

    context "with valid params" do
      before { post :create, :category => {:name => "Stuff"} }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should set_the_flash.to(/The (.*) category was created/) }
      it 'redirects back to categories' do
        response.should redirect_to(categories_url)
      end
    end

    describe "without valid params" do
      before { post :create, :category => {} }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should set_the_flash.now.to(/Couldn't save your category/) }
      it { should respond_with(:success) }
      it { should render_template(:new) }
    end

  end

  describe "PUT update" do

    before { login(moderator) }

    context "with valid params" do
      before { put :update, :id => category, :category => {:name => "Stuff"} }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should set_the_flash.to(/The (.*) category was saved/) }
      it 'redirects back to categories' do
        response.should redirect_to(categories_url)
      end
      it 'changes the name of the category' do
        assigns(:category).name.should eq('Stuff')
      end
    end

    context "without valid params" do
      before { put :update, :id => category, :category => {:name => ""} }
      it { should assign_to(:category).with_kind_of(Category) }
      it { should set_the_flash.now.to(/Couldn't save your category/) }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end

  end

end
