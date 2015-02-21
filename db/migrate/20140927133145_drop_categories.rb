class DropCategories < ActiveRecord::Migration
  def change
    drop_table :categories do |t|
      t.string :name, :description
      t.integer :position, :discussions_count, default: 0, null: false
      t.boolean :trusted, null: false, default: false
      t.timestamps
    end
    remove_column :exchanges, :category_id, :integer
  end
end
