# encoding: utf-8

require "rails_helper"
require "digest/md5"

describe AvatarsHelper do
  let(:email) { "foo@example.com" }
  let(:digest) { Digest::MD5.hexdigest(email) }

  describe "#gravatar_url" do
    subject { helper.gravatar_url(email) }

    it do
      is_expected.to eq(
        "https://secure.gravatar.com/avatar/#{digest}?s=24&r=x&d=identicon"
      )
    end
  end

  describe "#avatar_image_tag" do
    subject { helper.avatar_image_tag(user) }

    context "when user has an avatar uploaded" do
      let(:user) { create(:user_with_avatar, username: "foo") }
      it do
        is_expected.to match(
          Regexp.new(
            '<img alt="foo" class="avatar-image" ' +
              'src="\/avatars\/(.+)\/16x16\/1-([\d])+\.png" ' +
              'width="16" height="16" \/>'
          )
        )
      end
    end

    context "when user has email set" do
      let(:user) do
        build(:user, email: email, username: "foo")
      end
      it do
        is_expected.to eq(
          "<img alt=\"foo\" class=\"avatar-image\" " +
            "src=\"https://secure.gravatar.com/avatar/#{digest}?s=96&amp;r=x" +
            "&amp;d=identicon\" width=\"96\" height=\"96\" />"
        )
      end
    end

    context "when user doesn't have an email set" do
      let(:user) do
        create(:user, email: nil, username: "foo", facebook_uid: "123")
      end
      let(:digest) { Digest::MD5.hexdigest("#{user.id}@test.host") }
      it do
        is_expected.to eq(
          "<img alt=\"foo\" class=\"avatar-image\" " +
            "src=\"https://secure.gravatar.com/avatar/#{digest}?s=96&amp;r=x" +
            "&amp;d=identicon\" width=\"96\" height=\"96\" />"
        )
      end
    end
  end
end
