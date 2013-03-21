class PostUserAndTypeIndex < ActiveRecord::Migration
  def change
    add_index :posts, [:user_id, :conversation]
  end
end
