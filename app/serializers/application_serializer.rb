# frozen_string_literal: true

class ApplicationSerializer
  include FastJsonapi::ObjectSerializer

  class Helper
    include DynamicImage::Helper
    include Rails.application.routes.url_helpers
  end

  class << self
    def helper
      @helper ||= Helper.new
    end
  end
end
