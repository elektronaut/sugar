class AddDeletedToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :deleted, :boolean, default: false, null: false
    add_index :posts, :deleted
  end
end
