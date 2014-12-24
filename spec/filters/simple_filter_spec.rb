require 'spec_helper'

describe SimpleFilter do

  it "strips surrounding whitespace" do
    expect(SimpleFilter.new("  \n\n  foo  \n\n  ").to_html).to eq("foo")
  end

  it "converts line breaks to <br>" do
    expect(SimpleFilter.new("foo\n\nbar").to_html).to eq("foo<br>\n<br>\nbar")
  end

  it "escapes left angle brackets" do
    expect(SimpleFilter.new("<3").to_html).to eq("&lt;3")
  end

  it "escapes right angle brackets" do
    expect(SimpleFilter.new(">:/").to_html).to eq("&gt;:/")
  end

  it "doesn't escape tags" do
    expect(SimpleFilter.new("<a href=\"#\">link</a>").to_html).to eq("<a href=\"#\">link</a>")
  end

  it "doesn't escape right angle brackets after an empty attribute" do
    input = "<iframe src=\"//www.youtube.com/embed/Sq7XY_QRtzo\" allowfullscreen></iframe>\nfoo"
    output = "<iframe src=\"//www.youtube.com/embed/Sq7XY_QRtzo\" allowfullscreen></iframe><br>\nfoo"
    expect(SimpleFilter.new(input).to_html).to eq(output)
  end

end
