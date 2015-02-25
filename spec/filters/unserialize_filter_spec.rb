require "spec_helper"

describe UnserializeFilter do
  let(:data) { "hello world" }
  let(:encoded) { Base64.strict_encode64(data) }
  let(:filter) { UnserializeFilter.new(input) }

  context "when input contains a base64 serialized block" do
    let(:input) { "<base64serialized>#{encoded}</base64serialized>" }
    let(:output) { data }
    it "should decode the block" do
      expect(filter.to_html).to eq(output)
    end
  end
end
