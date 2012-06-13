# encoding: utf-8

class PostParser

  SYNTAXES = %w{applescript as3 actionscript3 bash shell cf coldfusion c# c-sharp csharp cpp c css diff delphi erl erlang groovy pascal pas patch js jscript javascript java javafx jfx Perl perl pl php plain text py python powershell ps rails ror ruby rb sass scss scala sql vb vbnet xml xhtml xslt html xhtml}

  def initialize(post)
    @original_post = post
  end

  def parse(post)
    post = post.strip

    # Wrap <code> content in CDATA
    post.gsub!(/(<code[\s\w\d\"\'=\-_\+\.]*>)/i){"#{$1}<![CDATA["}
    post.gsub!(/(<\/code>)/i){"]]>#{$1}"}

    # Normalize <script> tags so the parser will find them
    post.gsub!(/<script[\s\/]*/i, '<script ')

    # Parse the post
    doc = Hpricot(post)

    # Get all <code> blocks, store them elsewhere and replace them with
    # empty divs for now
    codeblocks = []
    doc.search('code') do |codeblock|
      if codeblock.attributes && codeblock.attributes['language']
        code_language = codeblock.attributes['language'].downcase.gsub(/[^\w\d_\.\-\+]/, '')
        code_language = 'plain' unless SYNTAXES.include?(code_language)
      else
        code_language = 'plain'
      end
      codeblock.swap("<div id=\"replace_codeblock_#{codeblocks.length}\"></div>")
      codeblocks << {
        :language => code_language,
        :body     => codeblock.children.first.content
      }
    end

    # Delete unsafe tags
    (doc/"script").remove
    (doc/"meta").remove

    # Filter malicious attributes on all elements
    doc.search("*").select{ |e| e.elem? }.each do |elem|
      if elem.raw_attributes
        elem.raw_attributes.each do |name, value|
          # XSS fix
          elem.raw_attributes.delete(name) if value && value.downcase.gsub(/[\\]*/, '') =~ /^[\s]*javascript\:/
          # Strip out event handlers
          elem.raw_attributes.delete(name) if name.downcase =~ /^on/
          # Change allowScriptAccess to sameDomain
          elem.raw_attributes[name] = 'sameDomain' if name.downcase =~ /^allowscriptaccess/
        end
      end
    end

    # Enforce correct allowScriptAccess on embed tags
    doc.search("embed").each do |elem|
      if elem.raw_attributes
        if !elem.raw_attributes.keys.map(&:downcase).include?('allowscriptaccess')
          elem.raw_attributes['allowScriptAccess'] = 'sameDomain'
        end
      else
        elem.raw_attributes = {'allowScriptAccess' => 'sameDomain'}
      end
    end

    # Filter param tags for malicious values
    doc.search("param").each do |elem|
      if elem.raw_attributes
        elem.raw_attributes.each do |name, value|
          # Change allowScriptAccess to sameDomain
          if name.downcase == 'name' && value.downcase == 'allowscriptaccess'
            elem.raw_attributes = {'name' => 'allowScriptAccess', 'value' => 'sameDomain'}
          end
        end
      end
    end

    # Make sure there's a <param name="allowScriptAccess" value="sameDomain"> in object tags
    doc.search("object").each do |elem|
      param_attributes = elem.search('>param').map do |subelem|
        if subelem.kind_of?(Hpricot::Elem)
          subelem.attributes ? subelem.attributes.to_hash.map{|k,v| (k.downcase == 'name') ? v.downcase : nil }.compact : []
        end
      end
      unless param_attributes.flatten.include?('allowscriptaccess')
        elem.inner_html += '<param name="allowScriptAccess" value="sameDomain" />'
      end
    end

    # ..and convert back to HTML again
    post = doc.to_html

    # Autolink URLs
    post.gsub!(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/){ "#{$1}<a href=\"#{$2}\">#{$2}</a>" }

    # Replace line breaks
    post.gsub!(/\r?\n/,'<br />')

    # Replace code blocks
    codeblocks.each_with_index do |codeblock, index|
      post.gsub!("<div id=\"replace_codeblock_#{index}\"></div>", '<pre class="code"><code class="'+codeblock[:language]+'">'+CGI::escapeHTML(codeblock[:body])+'</code></pre>')
    end

    post
  end

  def to_html
    (@parsed_post ||= parse(@original_post)).html_safe
  end
end
