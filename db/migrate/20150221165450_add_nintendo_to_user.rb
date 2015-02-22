class AddNintendoToUser < ActiveRecord::Migration
  def change
    add_column :users, :nintendo, :string
  end
end
