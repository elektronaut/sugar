class AddSonyToUser < ActiveRecord::Migration
  def change
  	add_column :users, :sony, :string
  end
end
