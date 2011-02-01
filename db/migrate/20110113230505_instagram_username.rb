class InstagramUsername < ActiveRecord::Migration
  def self.up
    add_column :users, :instagram, :string
  end

  def self.down
    remove_column :users, :instagram
  end
end
