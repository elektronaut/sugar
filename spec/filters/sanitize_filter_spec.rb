require "spec_helper"

describe SanitizeFilter do
  let(:filter) { SanitizeFilter.new(input) }

  context "when input contains a script tag" do
    let(:input) { "<form action=\"/\" method=\"post\"></form>" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains jQuery UJS attributes" do
    let(:input) { "<a href=\"/\" data-method=\"post\">foo</a>" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("<a href=\"/\">foo</a>")
    end
  end

  context "when input contains a script tag" do
    let(:input) { "<script>alert('foo');</script>" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains an applet tag" do
    let(:input) { "<applet code=\"wtf.class\">wtf</applet>" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains an base tag" do
    let(:input) { "<base href=\"http://example.com/\">" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains a meta tag" do
    let(:input) { "<meta name=\"foo\" content=\"bar\">" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains a link tag" do
    let(:input) { "<link rel=\"stylesheet\" href=\"theme.css\">" }
    it "should strip the tag" do
      expect(filter.to_html).to eq("")
    end
  end

  context "when input contains a javascript: URL attribute" do
    let(:input) { "<a href=\"javascript:alert('hi');\">link</a>" }
    let(:output) { "<a>link</a>" }
    it "should strip the attribute" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a javascript event handler" do
    let(:input) { "<img src=\"image.jpg\" onload=\"alert('hi');\">" }
    let(:output) { "<img src=\"image.jpg\">" }
    it "should strip the attribute" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an element with allowScriptAccess" do
    let(:input) do
      "<iframe src=\"/foo\" allowscriptaccess=\"always\"></iframe>"
    end
    let(:output) do
      "<iframe src=\"/foo\" allowscriptaccess=\"sameDomain\"></iframe>"
    end
    it "should set it to sameDomain" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an embed without allowScriptAccess" do
    let(:input) do
      "<embed src=\"/foo\"></embed>"
    end
    let(:output) do
      "<embed src=\"/foo\" allowScriptAccess=\"sameDomain\"></embed>"
    end
    it "should enforce the attribute" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains a param called allowScriptAccess" do
    let(:input) do
      "<param name=\"allowScriptAccess\" value=\"always\">"
    end
    let(:output) do
      "<param name=\"allowScriptAccess\" value=\"sameDomain\">"
    end
    it "should set the value to sameDomain" do
      expect(filter.to_html).to eq(output)
    end
  end

  context "when input contains an object tag" do
    context "and the object doesn't have an allowScriptAccess param" do
      let(:input) do
        "<object data=\"foo.swf\"></object>"
      end
      let(:output) do
        "<object data=\"foo.swf\">" \
          "<param name=\"allowScriptAccess\" value=\"sameDomain\">" \
          "</object>"
      end
      it "add the param" do
        expect(filter.to_html).to eq(output)
      end
    end

    context "and the object has an allowScriptAccess param" do
      let(:input) do
        "<object data=\"foo.swf\">" \
          "<param name=\"allowScriptAccess\" value=\"always\">" \
          "</object>"
      end
      let(:output) do
        "<object data=\"foo.swf\">" \
          "<param name=\"allowScriptAccess\" value=\"sameDomain\">" \
          "</object>"
      end
      it "should not add an extra param" do
        expect(filter.to_html).to eq(output)
      end
    end
  end
end
