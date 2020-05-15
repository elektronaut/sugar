# frozen_string_literal: true

require "rails_helper"

describe CodeFilter do
  let(:filter) { described_class.new(input) }

  context "when input contains <code> without <pre>" do
    let(:input) { "<code>code here</code>" }

    it "leave it alone" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when input contains <code> without language" do
    let(:input) { "<pre><code>code here</code></pre>" }
    let(:output) do
      "<div class=\"highlight\"><pre class=\"highlight\">" \
      "<code>code here</code></pre></div>"
    end

    it "syntaxes highlight it" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains <code> with language" do
    let(:input) { '<pre><code class="javascript">alert("foo")</code></pre>' }
    let(:output) { filter.to_html }

    it "syntaxes highlight it" do
      expect(output).to(
        match(%r{<pre class="highlight"><code>.*<span class="nx">alert</span>})
      )
    end
  end
end
