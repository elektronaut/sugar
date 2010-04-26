class CreateSettings < ActiveRecord::Migration
	def self.up
		create_table :settings do |t|
			t.string :key, :null => false
			t.text :value
		end
	end

	def self.down
		drop_table :settings
	end
end
