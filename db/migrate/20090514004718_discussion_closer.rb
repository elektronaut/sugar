class DiscussionCloser < ActiveRecord::Migration
	def self.up
		add_column :discussions, :closer_id, :integer
	end

	def self.down
		remove_column :discussions, :closer_id
	end
end
