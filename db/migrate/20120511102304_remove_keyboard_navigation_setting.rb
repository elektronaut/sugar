class RemoveKeyboardNavigationSetting < ActiveRecord::Migration
  def up
    remove_column :users, :keyboard_navigation
  end

  def down
    add_column :users, :keyboard_navigation, :boolean, :null => false, :default => true
  end
end