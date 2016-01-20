require "rails_helper"

describe LinkFilter do
  let(:filter) { LinkFilter.new(input) }

  context "when input contains a local link" do
    before { Sugar.config.domain_names = "b3s.me" }
    let(:input) { '<a href="https://b3s.me/path">foo</a>' }
    let(:output) { '<a href="/path">foo</a>' }
    it "should convert the link to a relative one" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an image on the HTTPS whitelist" do
    let(:input) { '<img src="http://i.imgur.com/test.gif">' }
    let(:output) { '<img src="//i.imgur.com/test.gif">' }
    it "should convert the URL to one without protocol" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an iframe on the HTTPS whitelist" do
    let(:input) { '<iframe src="http://youtube.com/foo"></iframe>' }
    let(:output) { '<iframe src="//youtube.com/foo"></iframe>' }
    it "should convert the URL to one without protocol" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an image not on the HTTPS whitelist" do
    let(:input) { "<img src=\"http://example.com/image.jpg\">" }

    context "and the image exists" do
      it "should rewrite the URL to one without protocol" do
        req = stub_request(:head, "https://example.com/image.jpg").
          to_return(status: 200)
        expect(filter.to_html).to eq("<img src=\"//example.com/image.jpg\">")
        assert_requested(req)
      end
    end

    context "and the image doesn't exists" do
      it "shouldn't change the URL" do
        req = stub_request(:head, "https://example.com/image.jpg").
          to_return(status: 404)
        expect(filter.to_html).to eq(input)
        assert_requested(req)
      end
    end

    context "and the server doesn't respond" do
      it "shouldn't change the URL" do
        req = stub_request(:head, "https://example.com/image.jpg").
          to_raise(SocketError)
        expect(filter.to_html).to eq(input)
        assert_requested(req)
      end
    end

    context "and an unexpected error occurs" do
      it "should log the error" do
        stub_request(:head, "https://example.com/image.jpg").
          to_raise("foo")
        expect(filter.logger).to receive(:error).
          with("Unexpected connection error #<StandardError: foo>")
        expect(filter.to_html).to eq(input)
      end
    end
  end
end
