require 'spec_helper'

describe SimpleFilter do

  it "strips surrounding whitespace" do
    SimpleFilter.new("  \n\n  foo  \n\n  ").to_html.should == "foo"
  end

  it "converts line breaks to <br>" do
    SimpleFilter.new("foo\n\nbar").to_html.should == "foo<br><br>bar"
  end

  it "should escape left angle brackets" do
    SimpleFilter.new("<3").to_html.should == "&lt;3"
  end

  it "should escape right angle brackets" do
    SimpleFilter.new(">:/").to_html.should == "&gt;:/"
  end

  it "should not escape tags" do
    SimpleFilter.new("<a href=\"#\">link</a>").to_html.should == "<a href=\"#\">link</a>"
  end

end