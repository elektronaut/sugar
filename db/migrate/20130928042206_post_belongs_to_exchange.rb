class PostBelongsToExchange < ActiveRecord::Migration
  def change
    rename_column :posts, :discussion_id, :exchange_id
  end
end
