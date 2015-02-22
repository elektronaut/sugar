class AddSteamToUser < ActiveRecord::Migration
  def change
  	add_column :users, :steam, :string
  end
end
