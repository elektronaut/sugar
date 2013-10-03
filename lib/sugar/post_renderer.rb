# encoding: utf-8

module Sugar
  class PostRenderer

    def initialize(post)
      @post = post.dup
    end

    def to_html
      parse!
      @post.html_safe
    end

    private

    def document
      @document ||= Hpricot(@post)
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Render::HTML.new(
        hard_wrap: true
      )
    end

    def markdown
      @markdown ||= Redcarpet::Markdown.new(
        markdown_renderer,
        no_intra_emphasis:   true,
        fenced_code_blocks:  true,
        autolink:            true,
        strikethrough:       true,
        lax_spacing:         true,
        space_after_headers: true
      )
    end

    # Parses the post
    def parse!
      prepare!
      remove_unsafe_tags!
      strip_event_handlers!
      enforce_allowscriptaccess!
      fetch_image_sizes!
      update_code_blocks!
      finalize!
    end

    def prepare!
      @post = @post.strip

      # Normalize <script> tags so the parser will find them
      @post.gsub!(/<script[\s\/]*/i, '<script ')

      # Convert image URLs to img tags
      @post.gsub!(/(^|\s)(((ftp|https?):)?\/\/[^\s]+\.(png|jpg|jpeg|gif)\b?)/) do
        "#{$1}<img src=\"#{$2}\">"
      end

      @post = markdown.render(@post)
    end

    def finalize!
      @post = document.to_html

      # Autolink URLs
      @post.gsub!(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/){ "#{$1}<a href=\"#{$2}\">#{$2}</a>" }
    end

    def update_code_blocks!
      # Fix legacy code blocks
      document.search('p > code') do |element|
        if element.attributes && !element.attributes["language"].blank?
          element.set_attribute "class", element.attributes["language"]
          element.raw_attributes.delete("language")
        else
          element.set_attribute "class", "plain"
        end
        element.parent.swap("<pre>#{element.to_html}</pre>")
      end
    end

    def fetch_image_sizes!
      document.search('img') do |element|
        if element.attributes && !element.attributes['src'].blank?
          url = element.attributes['src']
          if element.attributes['width'].blank? || element.attributes['height'].blank?
            if dimensions = FastImage.size(url, timeout: 2.0)
              width, height = dimensions
              element.set_attribute "width", width.to_s
              element.set_attribute "height", height.to_s
            end
          end
        end
      end
    end

    def remove_unsafe_tags!
      (document/"script").remove
      (document/"meta").remove
    end

    def strip_event_handlers!
      document.search("*").select{ |e| e.elem? }.each do |elem|
        if elem.raw_attributes
          elem.raw_attributes.each do |name, value|
            # XSS fix
            elem.raw_attributes.delete(name) if value && value.downcase.gsub(/[\\]*/, '') =~ /^[\s]*javascript\:/
            # Strip out event handlers
            elem.raw_attributes.delete(name) if name.downcase =~ /^on/
          end
        end
      end
    end

    # Enforces allowScriptAccess = sameDomain on iframes and other embeds.
    def enforce_allowscriptaccess!
      document.search("*").select{|e| e.elem?}.each do |element|
        change_allowscriptaccess_attribute_on(element)
      end

      document.search("embed").each do |element|
        enforce_allowscriptaccess_attribute_on(element)
      end

      # Change allowScriptAccess in param tags
      document.search("param").each do |element|
        change_allowscriptaccess_for_param(element)
      end

      # Make sure there's a <param name="allowScriptAccess" value="sameDomain"> in object tags
      document.search("object").each do |element|
        enforce_allowscriptaccess_param_in(element)
      end
    end

    # Changes allowScriptAccess to sameDomain on element if the attribute is present.
    def change_allowscriptaccess_attribute_on(element)
      if element.raw_attributes
        element.raw_attributes.each do |name, value|
          if name.downcase =~ /^allowscriptaccess/
            element.raw_attributes[name] = 'sameDomain'
          end
        end
      end
    end

    # Adds allowScriptAccess to element if the attribute isn't present.
    def enforce_allowscriptaccess_attribute_on(element)
      if element.raw_attributes
        if !element.raw_attributes.keys.map(&:downcase).include?('allowscriptaccess')
          element.raw_attributes['allowScriptAccess'] = 'sameDomain'
        end
      else
        element.raw_attributes = {'allowScriptAccess' => 'sameDomain'}
      end
    end

    # Changes value on param to sameDomain if name = allowScriptAccess.
    def change_allowscriptaccess_for_param(element)
      if element.raw_attributes
        element.raw_attributes.each do |name, value|
          # Change allowScriptAccess to sameDomain
          if name.downcase == 'name' && value.downcase == 'allowscriptaccess'
            element.raw_attributes = {'name' => 'allowScriptAccess', 'value' => 'sameDomain'}
          end
        end
      end
    end

    # Makes sure the element contains an allowScriptAccess param.
    def enforce_allowscriptaccess_param_in(element)
      param_attributes = element.search('>param').map do |subelement|
        if subelement.kind_of?(Hpricot::Elem)
          subelement.attributes ? subelement.attributes.to_hash.map{|k,v| (k.downcase == 'name') ? v.downcase : nil }.compact : []
        end
      end
      unless param_attributes.flatten.include?('allowscriptaccess')
        element.inner_html += '<param name="allowScriptAccess" value="sameDomain" />'
      end
    end

  end
end