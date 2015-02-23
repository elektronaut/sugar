class HideDiscussions < ActiveRecord::Migration
  def change
    add_column :discussion_relationships,
               :hidden, :boolean,
               default: false, null: false
    add_column :users, :hidden_count, :integer, default: 0, null: false
    add_index :discussion_relationships, :hidden
  end
end
