class RemoveUserDiscussionsCount < ActiveRecord::Migration
  def change
    remove_column :users, :discussions_count
  end
end
