require 'yaml'

Sugar.configure(YAML.load_file(File.join(File.dirname(__FILE__), '../sugar_conf.yml')))