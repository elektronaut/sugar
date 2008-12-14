class NotifyOnMessage < ActiveRecord::Migration
	def self.up
		add_column :users, :notify_on_message, :boolean, :default => 1, :null => false
	end

	def self.down
		remove_column :users, :notify_on_message
	end
end
