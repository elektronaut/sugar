class AddNintendoSwitchToUser < ActiveRecord::Migration
  def change
    add_column :users, :nintendo_switch, :string
  end
end
