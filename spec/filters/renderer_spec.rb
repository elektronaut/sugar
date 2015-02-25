require "spec_helper"

describe Renderer do
  describe ".filters" do
    let(:format) { "markdown" }
    subject { Renderer.filters(format) }

    it { is_expected.to include(AutolinkFilter) }
    it { is_expected.to include(CodeFilter) }
    it { is_expected.to include(ImageFilter) }
    it { is_expected.to include(LinkFilter) }
    it { is_expected.to include(SanitizeFilter) }

    context "when format is markdown" do
      it { is_expected.to include(MarkdownFilter) }
      it { is_expected.not_to include(MarkdownCodeFilter) }
      it { is_expected.not_to include(SimpleFilter) }
      it { is_expected.not_to include(UnserializeFilter) }
    end

    context "when format is html" do
      let(:format) { "html" }
      it { is_expected.to include(MarkdownCodeFilter) }
      it { is_expected.to include(SimpleFilter) }
      it { is_expected.to include(UnserializeFilter) }
      it { is_expected.not_to include(MarkdownFilter) }
    end
  end

  describe ".render" do
    subject { Renderer.render(input, format: format) }

    context "when format is markdown" do
      let(:format) { "markdown" }
      let(:input) { "*markdown*" }
      let(:output) { "<p><em>markdown</em></p>\n" }
      it "should render as Markdown" do
        expect(subject).to eq(output)
      end
    end

    context "when format is html" do
      let(:format) { "html" }
      let(:input) { "paragraph\n\nparagraph" }
      let(:output) { "paragraph<br>\n<br>\nparagraph" }
      it "should render through SimpleFilter" do
        expect(subject).to eq(output)
      end
    end
  end
end
