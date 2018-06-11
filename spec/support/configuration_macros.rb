# frozen_string_literal: true

module ConfigurationMacros
  def configure(configuration = {})
    Sugar.config.update(configuration)
  end
end
