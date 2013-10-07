# encoding: utf-8

module Sugar
  module PostRenderer
    class Filter
      attr_accessor :post

      def initialize(post)
        @post = post
      end

      def process(post)
        post
      end

      def to_html
        process(@post)
      end

    end
  end
end
