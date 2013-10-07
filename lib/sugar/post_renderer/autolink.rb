module Sugar
  module PostRenderer
    class Autolink < Sugar::PostRenderer::Filter

      def process(post)
        post.gsub(/(^|\s)((ftp|https?):\/\/[^\s]+\b\/?)/) do
          $1 + autolink($2)
        end
      end

      private

      def autolink(url)
        if url =~ /\.(jpg|jpeg|gif|png)$/i
          "<img src=\"#{url}\">"
        else
          "<a href=\"#{url}\">#{url}</a>"
        end
      end

    end
  end
end