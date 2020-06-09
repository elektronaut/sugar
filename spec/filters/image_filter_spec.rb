# frozen_string_literal: true

require "rails_helper"

describe ImageFilter do
  let(:image_url) { "http://example.com/image.jpg" }
  let(:filter) { described_class.new(input) }

  context "when img has no src" do
    let(:input) { '<img class="foo">' }

    it "is not touched" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when img has no size attributes" do
    let(:input) { "<img src=\"#{image_url}\">" }
    let(:output) { "<img src=\"#{image_url}\" width=\"640\" height=\"480\">" }

    it "fetches the image size" do
      allow(FastImage).to receive(:size)
        .with(image_url, timeout: 2.0)
        .and_return([640, 480])
      expect(filter.to_html).to eq(output)
    end
  end

  context "when img has only one size attribute" do
    let(:input) { "<img width=\"320\" src=\"#{image_url}\">" }
    let(:output) { "<img width=\"640\" src=\"#{image_url}\" height=\"480\">" }

    it "fetches the image size" do
      allow(FastImage).to receive(:size)
        .with(image_url, timeout: 2.0)
        .and_return([640, 480])
      expect(filter.to_html).to eq(output)
    end
  end

  context "when img has both size attributes" do
    let(:input) { "<img width=\"320\" height=\"240\" src=\"#{image_url}\">" }

    it "does not call FastImage" do
      allow(FastImage).to receive(:size).and_return(nil)
      input
      expect(FastImage).not_to have_received(:size)
    end

    it "is not touched" do
      expect(filter.to_html).to eq(input)
    end
  end
end
