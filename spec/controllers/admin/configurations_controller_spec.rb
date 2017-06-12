# encoding: utf-8

require "rails_helper"

describe Admin::ConfigurationsController, redis: true do
  let(:admin) { create(:admin) }

  it_requires_admin_for :show, :edit, :update

  context "when logged in as admin" do
    before { login(admin) }

    describe "show" do
      before { get :show }
      it "redirects to edit" do
        expect(response).to redirect_to(edit_admin_configuration_url)
      end
    end

    describe "edit" do
      before { get :edit }
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:edit) }
      specify { expect(flash[:notice]).to eq(nil) }
    end

    describe "update" do
      before { patch :update, params: { configuration: { forum_name: "New Forum Name" } } }
      specify { expect(flash[:notice]).to eq(nil) }

      it "should update the forum configuration" do
        expect(Sugar.config.forum_name).to eq("New Forum Name")
      end

      it "redirects back to edit" do
        expect(response).to redirect_to(edit_admin_configuration_url)
      end
    end
  end
end
