require "rails_helper"

describe CodeFilter do
  let(:filter) { CodeFilter.new(input) }

  context "when input contains <code> without <pre>" do
    let(:input) { "<code>code here</code>" }
    it "leave it alone" do
      expect(filter.to_html).to eq(input)
    end
  end

  context "when input contains <code> without language" do
    let(:input) { "<pre><code>code here</code></pre>" }
    let(:output) { "<div class=\"highlight\"><pre class=\"highlight\"><code>code here</code></pre></div>" }
    it "should syntax highlight it" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains <code> with language" do
    let(:input) { '<pre><code class="javascript">alert("foo")</code></pre>' }
    it "should syntax highlight it" do
      output = filter.to_html
      expect(output).to match(/<pre class="highlight"><code>/)
      expect(output).to match(%r{<span class="nx">alert</span>})
    end
  end
end
