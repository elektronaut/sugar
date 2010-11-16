class UserThemes < ActiveRecord::Migration
	def self.up
		add_column :users, :mobile_stylesheet_url, :string
		add_column :users, :theme, :string
		add_column :users, :mobile_theme, :string
	end

	def self.down
		remove_column :users, :mobile_stylesheet_url
		remove_column :users, :theme
		remove_column :users, :mobile_theme
	end
end
