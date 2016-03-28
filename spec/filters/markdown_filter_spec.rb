require "rails_helper"

describe MarkdownFilter do
  let(:filter) { MarkdownFilter.new(input) }

  context "when input contains a single line break" do
    let(:input) { "foo\nbar" }
    let(:output) { "<p>foo<br>\nbar</p>\n" }
    it "should convert it to <br>" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains adjacent blockquotes" do
    let(:input) { "> quote 1\n\n  > quote 2" }
    let(:output) do
      "<blockquote>\n<p>quote 1</p>\n</blockquote>\n\n" \
        "<blockquote>\n<p>quote 2</p>\n</blockquote>\n"
    end
    it "should convert it to <br>" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a spoiler tag" do
    let(:input) { '<div class="spoiler">*foo*</div>' }
    let(:output) { "<div class=\"spoiler\"><p><em>foo</em></p>\n</div>\n" }
    it "should convert the contents of the spoiler tag from Markdown" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a YouTube code" do
    let(:id) { "abcd" }
    let(:output) do
      "<iframe title=\"title\" src=\"https://www.youtube.com/embed/#{id}\" " \
        "frameborder=\"0\" allowfullscreen></iframe>\n"
    end

    context "when URL is a short URL" do
      let(:input) { "!y[title](https://youtu.be/#{id})" }
      it "should convert it to an embed" do
        expect(filter.to_html).to eq(output)
      end
    end

    context "when URL is a long URL" do
      let(:input) { "!y[title](https://www.youtube.com/watch?v=#{id})" }
      it "should convert it to an embed" do
        expect(filter.to_html).to eq(output)
      end
    end
  end
end
