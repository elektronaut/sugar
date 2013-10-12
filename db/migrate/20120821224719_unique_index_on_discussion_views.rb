class UniqueIndexOnDiscussionViews < ActiveRecord::Migration
  def up
    add_index :discussion_views, [:user_id, :discussion_id], name: 'user_id_discussion_id_index', unique: true
  end

  def down
    remove_index :discussion_views, name: 'user_id_discussion_id_index'
  end
end
