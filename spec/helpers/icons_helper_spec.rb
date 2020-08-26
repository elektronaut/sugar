# frozen_string_literal: true

require "rails_helper"

describe IconsHelper do
  describe "#icon_tags" do
    subject(:tags) { helper.icon_tags }

    it "renders favicons" do
      expect(tags).to(
        match(%r{<link rel="icon" href="/assets/icons/favicon-[\w\d]+\.ico})
      )
    end

    it "renders apple icons" do
      expect(tags).to(
        match(%r{<link\srel="apple-touch-icon-precomposed"\ssizes="144x144"\s
                 href="/assets/icons/apple-touch-icon-144x144-[\w\d]+\.png}x)
      )
    end

    it "renders windows icons" do
      expect(tags).to(
        match(%r{<meta\sname="msapplication-square150x150logo"\s
                 content="/assets/icons/mediumtile-[\w\d]+\.png}x)
      )
    end
  end
end
