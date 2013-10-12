require 'spec_helper'

describe Sugar::PostRenderer::Simple do
  let(:renderer) { Sugar::PostRenderer::Simple }

  it "strips surrounding whitespace" do
    renderer.new("  \n\n  foo  \n\n  ").to_html.should == "foo"
  end

  it "converts line breaks to <br>" do
    renderer.new("foo\n\nbar").to_html.should == "foo<br><br>bar"
  end

  it "should escape left angle brackets" do
    renderer.new("<3").to_html.should == "&lt;3"
  end

  it "should escape right angle brackets" do
    renderer.new(">:/").to_html.should == "&gt;:/"
  end

  it "should not escape tags" do
    renderer.new("<a href=\"#\">link</a>").to_html.should == "<a href=\"#\">link</a>"
  end

end