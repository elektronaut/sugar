# frozen_string_literal: true

class Configuration
  module ThemeSettings
    extend ActiveSupport::Concern
    included do
      setting :default_theme, :string, "default"
      setting :default_mobile_theme, :string, "default"
    end
  end
end
