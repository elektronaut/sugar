require "rails_helper"

describe AutolinkFilter do
  let(:filter) { AutolinkFilter.new(input) }
  let(:instagram_embed) do
    File.read(Rails.root.join("spec/support/requests/instagram_embed.json"))
  end
  let(:instagram_json) { JSON.parse(instagram_embed) }
  let(:twitter_embed) do
    File.read(Rails.root.join("spec/support/requests/twitter_embed.json"))
  end
  let(:twitter_json) { JSON.parse(twitter_embed) }

  context "when input contains a URL" do
    let(:input) { "http://example.com/foo?bar=1" }
    let(:output) { "<a href=\"#{input}\">#{input}</a>" }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a URL to a PNG file" do
    let(:input) { "http://example.com/folder/image.png" }
    let(:output) { '<img src="http://example.com/folder/image.png">' }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a URL to a JPEG file" do
    let(:input) { "http://example.com/folder/image.jpg" }
    let(:output) { '<img src="http://example.com/folder/image.jpg">' }
    it "should embed the image" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an image tag" do
    let(:input) { '<img src="http://example.com/folder/image.jpg">' }
    it "should leave it alone" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when input contains a URL to a GIFV file" do
    let(:input) { "http://i.imgur.com/abcdefg.gifv" }
    let(:output) { '<img src="http://i.imgur.com/abcdefg.gif">' }
    it "should embed it as a GIF" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when URL is an Instagram photo" do
    let(:input) { "https://www.instagram.com/p/8ql-VChPSZ/" }
    before do
      stub_request(
        :get,
        "https://api.instagram.com/oembed?" \
        "url=https://www.instagram.com/p/8ql-VChPSZ/"
      ).to_return(status: 200, body: instagram_embed)
    end

    it "should convert it to an embed" do
      expect(filter.to_html).to eq(instagram_json["html"])
    end
  end

  context "when URL is a Twitter status" do
    let(:input) { "https://twitter.com/Interior/status/463440424141459456" }
    before do
      stub_request(
        :get,
        "https://publish.twitter.com/oembed?" \
        "url=https://twitter.com/Interior/status/463440424141459456"
      ).to_return(status: 200, body: twitter_embed)
    end

    it "should convert it to an embed" do
      expect(filter.to_html).to eq(twitter_json["html"])
    end
  end

  context "when URL is a Twitter status without username" do
    let(:input) { "https://twitter.com/statuses/463440424141459456" }
    before do
      stub_request(
        :get,
        "https://publish.twitter.com/oembed?" \
        "url=https://twitter.com/twitter/status/463440424141459456"
      ).to_return(status: 200, body: twitter_embed)
    end

    it "should convert it to an embed" do
      expect(filter.to_html).to eq(twitter_json["html"])
    end
  end
end
