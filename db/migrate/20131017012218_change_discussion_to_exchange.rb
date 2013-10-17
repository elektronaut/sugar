class ChangeDiscussionToExchange < ActiveRecord::Migration
  def change
    rename_table :discussions, :exchanges
    rename_table :discussion_views, :exchange_views
    rename_column :exchange_views, :discussion_id, :exchange_id
  end
end
