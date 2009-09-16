class UserKeyboardToggle < ActiveRecord::Migration
	def self.up
		add_column :users, :keyboard_navigation, :boolean, :null => false, :default => true
	end

	def self.down
		remove_column :users, :keyboard_navigation
	end
end
