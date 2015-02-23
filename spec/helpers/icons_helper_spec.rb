# encoding: utf-8

require "spec_helper"

describe IconsHelper do
  describe "#icon_tags" do
    let(:icon_tags) do
      "<link rel=\"icon\" href=\"/assets/icons/favicon.ico\" " +
        "type=\"image/x-icon\" />" +
        "<link rel=\"icon\" href=\"/assets/icons/favicon.png\" " +
        "type=\"image/png\" />"
    end

    let(:apple_icon_tags) do
      "<link rel=\"apple-touch-icon-precomposed\" sizes=\"57x57\" " +
        "href=\"/assets/icons/apple-touch-icon-57x57.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"72x72\" " +
        "href=\"/assets/icons/apple-touch-icon-72x72.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"114x114\" " +
        "href=\"/assets/icons/apple-touch-icon-114x114.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"144x144\" " +
        "href=\"/assets/icons/apple-touch-icon-144x144.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"60x60\" " +
        "href=\"/assets/icons/apple-touch-icon-60x60.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"120x120\" " +
        "href=\"/assets/icons/apple-touch-icon-120x120.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"76x76\" " +
        "href=\"/assets/icons/apple-touch-icon-76x76.png\" />" +
        "<link rel=\"apple-touch-icon-precomposed\" sizes=\"152x152\" " +
        "href=\"/assets/icons/apple-touch-icon-152x152.png\" />"
    end

    let(:windows_icon_tags) do
      "<meta name=\"msapplication-square70x70logo\" " +
        "content=\"/assets/icons/smalltile.png\" />" +
        "<meta name=\"msapplication-square150x150logo\" " +
        "content=\"/assets/icons/mediumtile.png\" />" +
        "<meta name=\"msapplication-wide310x150logo\" " +
        "content=\"/assets/icons/widetile.png\" />" +
        "<meta name=\"msapplication-square310x310logo\" " +
        "content=\"/assets/icons/largetile.png\" />"
    end

    it "should render the icons" do
      expect(helper.icon_tags).to eq(
        icon_tags + apple_icon_tags + windows_icon_tags
      )
    end
  end
end
