class DropAvatarUrl < ActiveRecord::Migration
  def change
    remove_column :users, :avatar_url, :string
  end
end
