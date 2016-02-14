require "rails_helper"

describe PostImageFilter do
  let(:filter) { PostImageFilter.new(input) }
  let(:image) { create(:post_image) }
  let(:input) { "[image:#{image.id}:#{image.content_hash}]" }

  context "when input contains an embedded image" do
    it "should embed the image" do
      expect(filter.to_html).to match(
        %r{
        <img.alt="Pink".
        src="/post_images/([\w\d]+)/16x16/#{image.id}-([\w\d]+)\.png"
        .width="16".height="16"./>}x
      )
    end
  end

  context "when the hash is wrong" do
    let(:input) { "[image:#{image.id}:abc123]" }
    it "should not embed the image" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when image doesn't exist" do
    let(:image) { build(:post_image) }
    it "should not embed the image" do
      expect(filter.to_html).to eq(input)
    end
  end
end
