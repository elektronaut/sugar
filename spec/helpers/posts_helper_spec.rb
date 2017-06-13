# encoding: utf-8

require "rails_helper"

describe PostsHelper do
  let(:user) { create(:user, username: "foo") }
  let(:profile_link) { helper.profile_link(user, nil, class: :poster) }

  let(:smile_image) do
    '<img alt="smile" class="emoji" ' \
      'src="/images/emoji/unicode/1f604.png" ' \
      'style="vertical-align:middle" ' \
      'width="16" height="16" />'
  end

  describe "#emojify" do
    subject { helper.emojify(input) }

    context "when emoji is defined" do
      let(:input) { ":smile:" }
      it { is_expected.to match(smile_image) }
    end

    context "when emoji isn't defined" do
      let(:input) { ":foobar:" }
      it { is_expected.to eq(":foobar:") }
    end
  end

  describe "#format_post" do
    let(:input) { "/me :smile:" }
    subject { helper.format_post(input, user) }
    it { is_expected.to eq("#{profile_link} #{smile_image}") }
  end

  describe "#meify" do
    subject { helper.meify(input, user) }

    context "when string starts with /me" do
      let(:input) { "/me blushes" }
      it { is_expected.to eq(profile_link + " blushes") }
    end

    context "when string includes /me" do
      let(:input) { "checkout /me here" }
      it { is_expected.to eq("checkout #{profile_link} here") }
    end

    context "when /me isn't separated by spaces" do
      let(:input) { "b3s.me/me" }
      it { is_expected.to eq(input) }
    end
  end

  describe "#render_post" do
    it "should run the string through Renderer" do
      expect(Renderer).to receive(:render).with("foo").and_return("bar")
      expect(helper.render_post("foo")).to eq("bar")
    end
  end
end
