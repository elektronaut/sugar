module Sugar
  module PostRenderer
    class Simple < Sugar::PostRenderer::Filter

      def process(post)
        strip(post).gsub(/\r?\n/, "<br>")
      end

      private

      def strip(post)
        post.gsub(/\A[\s\n]*/, '').gsub(/[\s\n]*\Z/, '')
      end

    end
  end
end