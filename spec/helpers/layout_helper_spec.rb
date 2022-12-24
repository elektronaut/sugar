# frozen_string_literal: true

require "rails_helper"

describe LayoutHelper do
  describe "#body_class" do
    subject { helper.body_class }

    context "with no classes set" do
      it { is_expected.to eq("") }
    end

    context "when class is set" do
      before { helper.content_for :body_class, "foo" }

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
      %w[smiley laughing blush heart_eyes kissing_heart flushed worried
         grimacing cry angry heart star +1 -1].map do |name|
        { name: name,
          image: helper.image_path(
            "emoji/#{Emoji.find_by_alias(name).image_filename}",
            skip_pipeline: true
          ) }
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

    specify { expect(config[:debug]).to be(false) }
    specify { expect(config[:facebookAppId]).to eq("facebook") }
    specify { expect(config[:amazonAssociatesId]).to eq("amazon") }
    specify { expect(config[:uploads]).to be(true) }
    specify { expect(config[:emoticons]).to eq(default_emoticons) }

    context "when not logged in" do
      specify { expect(config[:currentUser]).to be_nil }
      specify { expect(config[:preferredFormat]).to be_nil }
    end

    context "when logged in" do
      let(:user) { build(:user, preferred_format: "html") }

      specify { expect(config[:currentUser]).to eq(user.as_json) }
      specify { expect(config[:preferredFormat]).to eq("html") }
    end
  end

  describe "#search_mode_options" do
    let(:options) { helper.search_mode_options }

    context "with no exchange" do
      specify do
        expect(options).to eq([
                                ["Discussions", helper.search_path],
                                ["Posts", helper.search_posts_path]
                              ])
      end
    end

    context "when exchange is set" do
      let(:discussion) { create(:discussion) }

      before { helper.instance_variable_set("@exchange", discussion) }

      specify do
        expect(options).to eq([["Discussions", helper.search_path],
                               ["Posts", helper.search_posts_path],
                               ["This discussion",
                                helper.polymorphic_path([:search_posts,
                                                         discussion])]])
      end
    end
  end

  describe "#header_tab" do
    let(:result) { helper.header_tab("Discussions", url) }

    let(:url) { "/discussions" }

    context "when not current section" do
      specify do
        expect(result).to eq(
          "<li class=\"discussions\"><a id=\"discussions_link\" " \
          "href=\"#{url}\">Discussions</a></li>"
        )
      end
    end

    context "when current section" do
      before { helper.instance_variable_set("@section", :discussions) }

      specify do
        expect(result).to eq(
          "<li class=\"discussions current\"><a id=\"discussions_link\" " \
          "href=\"#{url}\">Discussions</a></li>"
        )
      end
    end
  end
end
