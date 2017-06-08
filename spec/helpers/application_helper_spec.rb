# encoding: utf-8

require "rails_helper"

describe ApplicationHelper do
  describe "#facebook_oauth_url" do
    let(:redirect_url) { "http://example.com/foo" }
    before { Sugar.config.facebook_app_id = "123" }
    subject { helper.facebook_oauth_url(redirect_url) }
    it do
      is_expected.to eq(
        "https://www.facebook.com/dialog/oauth?client_id=123" \
          "&redirect_uri=http://example.com/foo" \
          "&scope=email"
      )
    end
  end

  describe "#pretty_link" do
    subject { helper.pretty_link(url) }

    context "when URL lacks http://" do
      let(:url) { "example.com" }
      it { is_expected.to eq('<a href="http://example.com">example.com</a>') }
    end

    context "when URL is valid" do
      let(:url) { "https://ex.com/" }
      it { is_expected.to eq('<a href="https://ex.com">ex.com</a>') }
    end

    context "when URL has a path" do
      let(:url) { "https://ex.com/foo/" }
      it do
        is_expected.to eq('<a href="https://ex.com/foo/">ex.com/foo/</a>')
      end
    end
  end

  describe "#possessive" do
    subject { helper.possessive(noun) }

    context "when word ends with 's'" do
      let(:noun) { "Charles" }
      it { is_expected.to eq("Charles'") }
    end

    context "when word doesn't end with 's'" do
      let(:noun) { "Inge" }
      it { is_expected.to eq("Inge's") }
    end
  end

  describe "#profile_link" do
    let(:user) { build(:user, username: "foo") }
    subject { helper.profile_link(user) }

    context "when user is nil" do
      let(:user) { nil }
      it { is_expected.to eq("Unknown") }
    end

    context "when user exists" do
      it do
        is_expected.to eq(
          '<a title="foo&#39;s profile" href="/users/profile/foo">foo</a>'
        )
      end
    end

    context "when link text is set" do
      subject { helper.profile_link(user, "Profile") }
      it do
        is_expected.to eq(
          '<a title="foo&#39;s profile" href="/users/profile/foo">Profile</a>'
        )
      end
    end
  end
end
