# encoding: utf-8

require "rails_helper"

describe PostsController do
  # Create the first admin user
  before { create(:user) }

  let(:user)          { create(:user) }
  let(:discussion)    { create(:discussion) }
  let(:existing_post) { create(:post, exchange: discussion, user: user) }

  describe "POST create" do
    before { login(user) }

    context "with valid params" do
      let(:post_params) { { body: "foo", format: "html" } }

      context "HTML format" do
        before { post :create, params: { discussion_id: discussion.id, post: post_params } }
        specify { expect(assigns(:post)).to be_valid }
        it "redirects back to the discussion" do
          expect(response).to redirect_to(
            discussion_url(
              discussion,
              page: 1,
              anchor: "post-#{assigns(:post).id}"
            )
          )
        end
      end

      context "mobile format" do
        before do
          post(
            :create,
            params: {
              discussion_id: discussion.id,
              post: post_params
            },
            format: :mobile
          )
        end

        it "redirects back to the discussion" do
          expect(response).to redirect_to(
            discussion_url(
              discussion,
              page: 1,
              anchor: "post-#{assigns(:post).id}"
            )
          )
        end
      end

      context "JSON format" do
        before do
          post(
            :create,
            params: {
              discussion_id: discussion.id,
              post: post_params
            },
            format: :json
          )
        end
        specify { expect(assigns(:post)).to be_valid }
        it { is_expected.to respond_with(:created) }
        specify { expect(response.body).to be_json_eql(assigns(:post).to_json) }
      end
    end

    context "with invalid params" do
      let(:post_params) { { body: "", format: "html" } }

      context "HTML format" do
        before { post :create, params: { discussion_id: discussion.id, post: post_params } }
        specify { expect(assigns(:post)).to_not be_valid }
        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:new) }
      end

      context "JSON format" do
        before do
          post(
            :create,
            params: {
              discussion_id: discussion.id,
              post: post_params
            },
            format: :json
          )
        end
        specify { expect(assigns(:post)).to_not be_valid }
        it { is_expected.to respond_with(:unprocessable_entity) }
      end
    end
  end

  describe "PUT update" do
    before { login(user) }

    context "with valid params" do
      let(:post_params) { { body: "foo", format: "html" } }

      context "HTML format" do
        before do
          put(
            :update,
            params: {
              discussion_id: existing_post.exchange_id,
              id: existing_post.id,
              post: post_params
            }
          )
        end
        specify { expect(assigns(:post)).to be_valid }
        it "redirects back to the discussion" do
          expect(response).to redirect_to(
            discussion_url(
              discussion, page: 1, anchor: "post-#{assigns(:post).id}"
            )
          )
        end
      end

      context "JSON format" do
        before do
          put(
            :update,
            params: {
              discussion_id: existing_post.exchange_id,
              id: existing_post.id,
              post: post_params
            },
            format: :json
          )
        end
        specify { expect(assigns(:post)).to be_valid }
        it { is_expected.to respond_with(:no_content) }
      end
    end

    context "with invalid params" do
      let(:post_params) { { body: "", format: "wrong_format" } }

      context "HTML format" do
        before do
          put(
            :update,
            params: {
              discussion_id: existing_post.exchange_id,
              id: existing_post.id,
              post: post_params
            }
          )
        end
        specify { expect(assigns(:post)).to_not be_valid }
        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:edit) }
      end

      context "JSON format" do
        before do
          put(
            :update,
            params: {
              discussion_id: existing_post.exchange_id,
              id: existing_post.id,
              post: post_params
            },
            format: :json
          )
        end
        specify { expect(assigns(:post)).to_not be_valid }
        it { is_expected.to respond_with(:unprocessable_entity) }
      end
    end
  end
end
