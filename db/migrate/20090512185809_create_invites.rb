class CreateInvites < ActiveRecord::Migration
	def self.up
		create_table :invites do |t|
			t.belongs_to :user
			t.string     :email, :token
			t.text       :message
			t.datetime   :expires_at
			t.timestamps
		end
		add_column :users, :available_invites, :integer, :null => false, :default => 0
	end

	def self.down
		drop_table :invites
		remove_column :users, :available_invites
	end
end
