require "rails_helper"

describe MarkdownCodeFilter do
  let(:filter) { MarkdownCodeFilter.new(input) }

  context "when input contains a Markdown fenced code blocks" do
    let(:input) { "```ruby\nputs hello world\n```" }
    let(:parsed) { MarkdownFilter.new(input).to_html.strip }
    let(:serialized) { Base64.strict_encode64(parsed) }
    it "should filter and base64 serialize the block" do
      expect(filter.to_html).to eq(
        "<base64serialized>#{serialized}</base64serialized>"
      )
    end
  end
end
