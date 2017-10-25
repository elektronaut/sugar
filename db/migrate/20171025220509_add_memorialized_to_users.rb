class AddMemorializedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :memorialized, :boolean, null: false, default: false
  end
end
