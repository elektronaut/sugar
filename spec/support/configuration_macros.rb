module ConfigurationMacros
  def configure(configuration={})
    Sugar.configure(configuration)
    Sugar.save_config!
  end
end