require 'spec_helper'

describe SimpleFilter do

  it "strips surrounding whitespace" do
    SimpleFilter.new("  \n\n  foo  \n\n  ").to_html.should == "foo"
  end

  it "converts line breaks to <br>" do
    SimpleFilter.new("foo\n\nbar").to_html.should == "foo<br>\n<br>\nbar"
  end

  it "escapes left angle brackets" do
    SimpleFilter.new("<3").to_html.should == "&lt;3"
  end

  it "escapes right angle brackets" do
    SimpleFilter.new(">:/").to_html.should == "&gt;:/"
  end

  it "doesn't escape tags" do
    SimpleFilter.new("<a href=\"#\">link</a>").to_html.should == "<a href=\"#\">link</a>"
  end

  it "doesn't escape right angle brackets after an empty attribute" do
    input = "<iframe src=\"//www.youtube.com/embed/Sq7XY_QRtzo\" allowfullscreen></iframe>\nfoo"
    output = "<iframe src=\"//www.youtube.com/embed/Sq7XY_QRtzo\" allowfullscreen></iframe><br>\nfoo"
    SimpleFilter.new(input).to_html.should == output
  end

end