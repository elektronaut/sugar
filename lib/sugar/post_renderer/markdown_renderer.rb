# encoding: utf-8

module Sugar
  module PostRenderer
    class MarkdownRenderer < Redcarpet::Render::HTML
      def autolink(link, link_type)
        if link =~ /\.(jpg|jpeg|gif|png)$/i
          "<img src=\"#{link}\">"
        else
          "<a href=\"#{link}\">#{link}</a>"
        end
      end
    end
  end
end