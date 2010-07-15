class TemporaryBan < ActiveRecord::Migration
	def self.up
		add_column :users, :time_zone, :string
		add_column :users, :banned_until, :datetime
	end

	def self.down
		remove_column :users, :time_zone
		remove_column :users, :banned_until
	end
end
