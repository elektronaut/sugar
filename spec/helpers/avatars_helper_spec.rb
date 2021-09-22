# frozen_string_literal: true

require "rails_helper"
require "digest/md5"

describe AvatarsHelper do
  let(:email) { "foo@example.com" }
  let(:digest) { Digest::MD5.hexdigest(email) }

  describe "#gravatar_url" do
    subject { helper.gravatar_url(email) }

    let(:url) do
      "https://secure.gravatar.com/avatar/#{digest}?s=24&r=x&d=identicon"
    end

    it { is_expected.to eq(url) }
  end

  describe "#avatar_image_tag" do
    subject { helper.avatar_image_tag(user) }

    context "when user has an avatar uploaded" do
      let(:user) { create(:user_with_avatar, username: "foo") }
      let(:expression) do
        Regexp.new('<img alt="foo" class="avatar-image" ' \
                   'src="\/avatars\/(.+)\/16x16\/1-([\d])+\.png" ' \
                   'width="16" height="16" \/>')
      end

      it { is_expected.to match(expression) }
    end

    context "when user has email set" do
      let(:user) do
        build(:user, email: email, username: "foo")
      end
      let(:output) do
        '<img alt="foo" class="avatar-image" ' \
          "src=\"https://secure.gravatar.com/avatar/#{digest}?s=96&amp;r=x" \
          '&amp;d=identicon" width="96" height="96" />'
      end

      it { is_expected.to eq(output) }
    end

    context "when user doesn't have an email set" do
      let(:user) do
        create(:user, username: "foo").tap { |u| u.email = nil }
      end
      let(:digest) { Digest::MD5.hexdigest("#{user.id}@test.host") }
      let(:output) do
        '<img alt="foo" class="avatar-image" ' \
          "src=\"https://secure.gravatar.com/avatar/#{digest}?s=96&amp;r=x" \
          '&amp;d=identicon" width="96" height="96" />'
      end

      it { is_expected.to eq(output) }
    end
  end
end
