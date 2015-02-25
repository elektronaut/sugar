require "spec_helper"

describe AutolinkFilter do
  let(:filter) { AutolinkFilter.new(input) }

  context "when input contains a URL" do
    let(:input) { "http://example.com/foo?bar=1" }
    let(:output) { "<a href=\"#{input}\">#{input}</a>" }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a URL to a PNG file" do
    let(:input) { "http://example.com/folder/image.png" }
    let(:output) { "<img src=\"http://example.com/folder/image.png\">" }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a URL to a JPEG file" do
    let(:input) { "http://example.com/folder/image.jpg" }
    let(:output) { "<img src=\"http://example.com/folder/image.jpg\">" }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an image tag" do
    let(:input) { "<img src=\"http://example.com/folder/image.jpg\">" }
    it "should leave it alone" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when input contains a URL to a GIF file on imgur" do
    let(:input) { "http://i.imgur.com/abcdefg.gif" }
    let(:output) do
      "<video loop controls autoplay>" +
        "<source src=\"http://i.imgur.com/abcdefg.mp4\" type=\"video/mp4\">" +
        "</video>"
    end
    it "should embed it as video" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a URL to a GIFV file on imgur" do
    let(:input) { "http://i.imgur.com/abcdefg.gifv" }
    let(:output) do
      "<video loop controls autoplay>" +
        "<source src=\"http://i.imgur.com/abcdefg.mp4\" type=\"video/mp4\">" +
        "</video>"
    end
    it "should embed it as video" do
      expect(filter.to_html).to eq(output)
    end
  end
end
