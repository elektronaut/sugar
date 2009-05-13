class UserApplication < ActiveRecord::Migration
	def self.up
		add_column :users, :application, :text
	end

	def self.down
		remove_column :users, :application
	end
end
