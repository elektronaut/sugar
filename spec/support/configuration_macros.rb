module ConfigurationMacros
  def configure(configuration = {})
    Sugar.config.update(configuration)
  end
end
