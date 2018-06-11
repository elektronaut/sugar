# frozen_string_literal: true

require "rails_helper"

describe Renderer do
  describe ".filters" do
    subject { described_class.filters(format) }

    let(:format) { "markdown" }

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
    let(:rendered) { described_class.render(input, format: format) }

    context "when format is markdown" do
      let(:format) { "markdown" }
      let(:input) { "*markdown*" }
      let(:output) { "<p><em>markdown</em></p>\n" }

      it "renders as Markdown" do
        expect(rendered).to eq(output)
      end
    end

    context "when format is html" do
      let(:format) { "html" }
      let(:input) { "paragraph\n\nparagraph" }
      let(:output) { "paragraph<br>\n<br>\nparagraph" }

      it "renders through SimpleFilter" do
        expect(rendered).to eq(output)
      end
    end
  end
end
