# encoding: utf-8

require "rails_helper"

describe ImageFetcher do
  describe ".fetch" do
    let(:url) { "http://i.imgur.com/foobar.png" }
    let(:image) { PostImage.last }
    let(:body) { "#{url}" }
    subject { ImageFetcher.fetch(body) }

    before do
      stub_request(:get, url).
        to_return(
          status: 200,
          body: File.open(Rails.root.join("spec/support/pink.png"), "rb"),
          headers: { "Content-Type" => "image/png" }
        )
    end

    context "when image is autolinked" do
      it { is_expected.to eq("[image:#{image.id}:#{image.content_hash}]") }
    end

    context "when image is embedded with Markdown" do
      let(:body) { "![This is an image](#{url})" }
      it { is_expected.to eq("[image:#{image.id}:#{image.content_hash}]") }
    end

    context "when image is embedded with <img> tag" do
      let(:body) { "<img src=\"#{url}\" alt=\"foo\">" }
      it { is_expected.to eq("[image:#{image.id}:#{image.content_hash}]") }
    end

    context "when image is embedded with <img /> tag" do
      let(:body) { "<img src=\"#{url}\" alt=\"foo\" />" }
      it { is_expected.to eq("[image:#{image.id}:#{image.content_hash}]") }
    end

    context "when image is not on the whitelist" do
      let(:body) { "http://example.com/example.jpg" }
      it { is_expected.to eq(body) }
    end

    context "when image is not on the whitelist, Markdown syntax" do
      let(:body) { "![](http://example.com/example.jpg)" }
      it { is_expected.to eq(body) }
    end

    context "when image has already been fetched" do
      let!(:image) { create(:post_image, original_url: url) }
      it { is_expected.to eq("[image:#{image.id}:#{image.content_hash}]") }
    end

    context "when image doesn't exist" do
      before do
        stub_request(:get, url).
          to_return(status: 404, body: "Not Found")
      end
      it { is_expected.to eq(body) }
    end

    it "should get the filename" do
      ImageFetcher.fetch(body)
      expect(image.filename).to eq("foobar.png")
    end

    it "should get the content type" do
      ImageFetcher.fetch(body)
      expect(image.content_type).to eq("image/png")
    end

    it "should set the original URL" do
      ImageFetcher.fetch(body)
      expect(image.original_url).to eq(url)
    end
  end
end
