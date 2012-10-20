class Setting < ActiveRecord::Base
  class << self
    def set(key, value)
      key = key.to_s
      value = 0 if value === false
      value = 1 if value === true
      value = nil if value === ''
      setting = Setting.find_by_key(key)
      setting ||= Setting.create(:key => key)
      setting.update_attribute(:value, value)
    end
  end
end

class RemoveSettings < ActiveRecord::Migration
  def up
    results = ActiveRecord::Base.connection.select_rows('SELECT * FROM settings')
    configuration = results.inject({}) do |config, record|
      config[record['key'].to_sym] = record['value']
      config
    end
    Sugar.update_configuration(configuration)
    drop_table :settings
  end

  def down
    create_table :settings do |t|
      t.string :key, :null => false
      t.text :value
    end
    Sugar.config.each do |key, value|
      Setting.set(key, value)
    end
  end
end
