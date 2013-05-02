# encoding: utf-8

require 'spec_helper'

describe CategoriesController do

  # Create the first admin user
  before { create(:user) }

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
      specify { assigns(:category).should be_a(Category) }
    end

    context "when category doesn't exist" do
      let(:category_id) { 1231241 }
      specify { assigns(:category).should be_nil }
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
    specify { assigns(:categories).should be_a(ActiveRecord::Relation) }
    it { should respond_with(:success) }
    it { should render_template(:index) }
  end

  describe "GET show" do
    before { login; get :show, :id => category }
    specify { assigns(:category).should be_a(Category) }
    specify { assigns(:discussions).should be_a(ActiveRecord::Relation) }
    it { should respond_with(:success) }
    it { should render_template(:show) }
  end

  describe "GET new" do
    before { login(moderator); get :new }
    specify { assigns(:category).should be_a(Category) }
    it { should respond_with(:success) }
    it { should render_template(:new) }
  end

  describe "GET edit" do
    before { login(moderator); get :edit, id: category }
    specify { assigns(:category).should be_a(Category) }
    it { should respond_with(:success) }
    it { should render_template(:edit) }
  end

  describe "POST create" do

    before { login(moderator) }

    context "with valid params" do
      before { post :create, :category => {:name => "Stuff"} }
      specify { assigns(:category).should be_a(Category) }
      specify { flash[:notice].should match(/The (.*) category was created/) }
      it 'redirects back to categories' do
        response.should redirect_to(categories_url)
      end
    end

    describe "without valid params" do
      before { post :create, :category => {} }
      specify { assigns(:category).should be_a(Category) }
      specify { flash.now[:notice].should match(/Couldn't save your category/) }
      it { should respond_with(:success) }
      it { should render_template(:new) }
    end

  end

  describe "PUT update" do

    before { login(moderator) }

    context "with valid params" do
      before { put :update, :id => category, :category => {:name => "Stuff"} }
      specify { assigns(:category).should be_a(Category) }
      specify { flash[:notice].should match(/The (.*) category was saved/) }
      it 'redirects back to categories' do
        response.should redirect_to(categories_url)
      end
      it 'changes the name of the category' do
        assigns(:category).name.should eq('Stuff')
      end
    end

    context "without valid params" do
      before { put :update, :id => category, :category => {:name => ""} }
      specify { assigns(:category).should be_a(Category) }
      specify { flash[:notice].should match(/Couldn't save your category/) }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end

  end

end
