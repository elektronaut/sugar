class FacebookUid < ActiveRecord::Migration
	def self.up
		add_column :users, :facebook_uid, :string
	end

	def self.down
		remove_column :users, :facebook_uid
	end
end
