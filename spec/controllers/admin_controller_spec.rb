# encoding: utf-8

require 'spec_helper'

describe AdminController, redis: true do

  let(:admin) { create(:admin) }

  it_requires_admin_for :configuration

  context "when logged in as admin" do
    before { login(admin) }

    describe "GET configuration" do
      before { get :configuration }
      it { should respond_with(:success) }
      it { should render_template(:configuration) }
      it { should_not set_the_flash }
    end

    describe "POST configuration" do
      before { post :configuration, config: {forum_name: "New Forum Name"} }
      it { should respond_with(:success) }
      it { should render_template(:configuration) }
      it { should_not set_the_flash }
      it 'should update the forum configuration' do
        Sugar.config(:forum_name).should == "New Forum Name"
      end
    end

  end

end