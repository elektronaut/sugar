require 'spec_helper'

describe CodeFilter do

  it "converts language attribute to class" do
    input  = "<pre><code language=\"ruby\">foo</code></pre>"
    output = "<pre><code class=\"ruby\">foo</code></pre>"
    CodeFilter.new(input).to_html.should == output
  end

  it "wraps code with class in a <pre>" do
    input  = "<code class=\"ruby\">foo</code>"
    output = "<pre><code class=\"ruby\">foo</code></pre>"
    CodeFilter.new(input).to_html.should == output
  end

  it "doesn't wrap code already in a <pre>" do
    input  = "<pre><code class=\"ruby\">foo</code></pre>"
    output = "<pre><code class=\"ruby\">foo</code></pre>"
    CodeFilter.new(input).to_html.should == output
  end

end