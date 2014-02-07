# encoding: utf-8

require 'spec_helper'

describe Admin::ConfigurationsController, redis: true do

  let(:admin) { create(:admin) }

  it_requires_admin_for :show, :edit, :update

  context "when logged in as admin" do
    before { login(admin) }

    describe "show" do
      before { get :show }
      it 'redirects to edit' do
        response.should redirect_to(edit_admin_configuration_url)
      end
    end

    describe "edit" do
      before { get :edit }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
      specify { flash[:notice].should be_nil }
    end

    describe "update" do
      before { patch :update, configuration: { forum_name: "New Forum Name" } }
      specify { flash[:notice].should be_nil }
      it 'should update the forum configuration' do
        Sugar.config.forum_name.should == "New Forum Name"
      end
      it 'redirects back to edit' do
        response.should redirect_to(edit_admin_configuration_url)
      end
    end

  end

end