# encoding: utf-8

require "rails_helper"

describe DiscussionsController do
  let(:user) { create(:user) }

  # Create the first admin user
  before { create(:user) }

  describe "with public browsing off" do
    before { Sugar.config.update(public_browsing: false) }

    it_requires_login_for :index, :search, :new, :create
    it_requires_login_for :favorites, :following
    it_requires_login_for :show, :edit, :update
    it_requires_login_for :follow, :unfollow, :favorite, :unfavorite
  end

  describe "with public browsing on" do
    before { Sugar.config.update(public_browsing: true) }

    it_requires_login_for :new, :create, :favorites, :following
    it_requires_login_for :edit, :update,
                          :follow, :unfollow,
                          :favorite, :unfavorite

    it "is open for browsing discussions and posts" do
      discussion = create(:discussion)
      [:index, :show].each do |action|
        get action, params: { id: discussion }
        should respond_with(:success)
      end
    end
  end

  describe "GET index" do
    before do
      get :index
    end

    specify { expect(assigns(:exchanges)).to be_a(ActiveRecord::Relation) }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:index) }
  end

  describe "GET show" do
    before do
      discussion = create(:discussion)
      get :show, params: { id: discussion }
    end

    specify { expect(assigns(:exchange)).to be_a(Discussion) }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:show) }
  end

  describe "GET new" do
    before { login }

    context "Starting a new discussion" do
      before { get :new }
      specify { expect(assigns(:exchange)).to be_a(Discussion) }
      it { is_expected.to render_template(:new) }
    end
  end

  describe "POST create" do
    before { login }

    context "with invalid params" do
      before { post :create, params: { discussion: { foo: "bar" } } }
      it { is_expected.to render_template(:new) }
      specify do
        expect(flash.now[:notice]).to match(
          Regexp.new(
            "Could not save your discussion! " \
            "Please make sure all required fields are filled in"
          )
        )
      end
    end

    context "when creating a discussion" do
      before { post :create, params: { discussion: { title: "Test", body: "Test" } } }
      specify { expect(assigns(:exchange)).to be_a(Discussion) }
      it { is_expected.to redirect_to(discussion_url(assigns(:exchange))) }
    end
  end
end
