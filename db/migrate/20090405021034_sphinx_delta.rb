class SphinxDelta < ActiveRecord::Migration
	def self.up
		add_column :posts,       :delta, :boolean, :null => false, :default => false
		add_column :discussions, :delta, :boolean, :null => false, :default => false
		add_index  :posts,       :delta, :name => 'delta_index'
		add_index  :discussions, :delta, :name => 'delta_index'
	end

	def self.down
		remove_column :posts,       :delta
		remove_column :discussions, :delta
	end
end
