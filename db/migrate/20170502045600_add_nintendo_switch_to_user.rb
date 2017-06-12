class AddNintendoSwitchToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :nintendo_switch, :string
  end
end
