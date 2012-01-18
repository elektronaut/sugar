class RemoveFacebookAccessToken < ActiveRecord::Migration
	def up
		remove_column :users, :facebook_access_token
	end

	def down
		add_column :users, :facebook_access_token, :string
	end
end
