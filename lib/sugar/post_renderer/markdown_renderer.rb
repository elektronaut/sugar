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

      def preprocess(document)
        escape_leading_gts_without_space(document)
      end

      def escape_leading_gts_without_space(document)
        document.gsub(/^([\s]*)([>]+)([^\s>])/) { $1 + ("&gt;" * $2.length) + $3 }
      end
    end
  end
end