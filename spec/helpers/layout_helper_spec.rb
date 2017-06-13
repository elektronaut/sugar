# encoding: utf-8

require "rails_helper"

describe LayoutHelper do
  describe "#add_body_class" do
    before { helper.add_body_class(class_name) }
    subject { helper.body_classes }

    context "when argument is a string" do
      let(:class_name) { "foo" }
      it { is_expected.to include("foo") }
    end

    context "when argument is an array" do
      let(:class_name) { %w(foo bar) }
      it { is_expected.to eq("foo bar") }
    end
  end

  describe "#body_classes" do
    subject { helper.body_classes }

    context "default value" do
      it { is_expected.to eq("") }
    end

    context "when classes are added" do
      before { helper.add_body_class("foo") }
      it { is_expected.to eq("foo") }
    end

    context "when body has a sidebar" do
      before { helper.content_for :sidebar, "Sidebar" }
      it { is_expected.to eq("with_sidebar") }
    end
  end

  describe "#frontend_configuration" do
    let(:user) { nil }
    let(:config) { helper.frontend_configuration }
    let(:default_emoticons) do
      %w(smiley laughing blush heart_eyes kissing_heart flushed worried
         grimacing cry angry heart star +1 -1).map do |name|
        {
          name: name,
          image: helper.image_path(
            "emoji/" + Emoji.find_by_alias(name).image_filename,
            skip_pipeline: true
          )
        }
      end
    end

    before do
      Sugar.config.reset!
      Sugar.config.update(
        facebook_app_id: "facebook",
        amazon_associates_id: "amazon"
      )
      allow(helper).to receive(:current_user).and_return(user)
      allow(Sugar).to receive(:aws_s3?).and_return(true)
    end

    specify { expect(config[:debug]).to eq(false) }
    specify { expect(config[:facebookAppId]).to eq("facebook") }
    specify { expect(config[:amazonAssociatesId]).to eq("amazon") }
    specify { expect(config[:uploads]).to eq(true) }
    specify { expect(config[:emoticons]).to eq(default_emoticons) }

    context "when not logged in" do
      specify { expect(config[:currentUser]).to eq(nil) }
      specify { expect(config[:preferredFormat]).to eq(nil) }
    end

    context "when logged in" do
      let(:user) { build(:user, preferred_format: "html") }
      specify { expect(config[:currentUser]).to eq(user.as_json) }
      specify { expect(config[:preferredFormat]).to eq("html") }
    end
  end

  describe "#search_mode_options" do
    subject { helper.search_mode_options }

    context "with no exchange" do
      specify do
        expect(subject).to eq([
                                ["in discussions", helper.search_path],
                                ["in posts", helper.search_posts_path]
                              ])
      end
    end

    context "when exchange is set" do
      let(:discussion) { create(:discussion) }
      before { helper.instance_variable_set("@exchange", discussion) }
      specify do
        expect(subject).to eq(
          [
            ["in discussions", helper.search_path],
            ["in posts", helper.search_posts_path],
            [
              "in this discussion",
              helper.polymorphic_path([:search_posts, discussion])
            ]
          ]
        )
      end
    end
  end

  describe "#header_tab" do
    let(:url) { "/discussions" }
    subject { helper.header_tab("Discussions", url) }

    context "when not current section" do
      specify do
        expect(subject).to eq(
          "<li class=\"discussions\"><a id=\"discussions_link\" " \
            "href=\"#{url}\">Discussions</a></li>"
        )
      end
    end

    context "when current section" do
      before { helper.instance_variable_set("@section", :discussions) }
      specify do
        expect(subject).to eq(
          "<li class=\"discussions current\"><a id=\"discussions_link\" " \
            "href=\"#{url}\">Discussions</a></li>"
        )
      end
    end
  end
end
