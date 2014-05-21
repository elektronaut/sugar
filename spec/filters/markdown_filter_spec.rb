require 'spec_helper'

describe MarkdownFilter do

  it "converts line breaks to <br>" do
    input  = "foo\nbar"
    output = "<p>foo<br>\nbar</p>\n"
    MarkdownFilter.new(input).to_html.should == output
  end

  it "converts adjacent blockquotes to separate tags" do
    input  = "> quote 1\n\n  > quote 2"
    output = "<blockquote>\n<p>quote 1</p>\n</blockquote>\n\n<blockquote>\n<p>quote 2</p>\n</blockquote>\n"
    MarkdownFilter.new(input).to_html.should == output
  end
end