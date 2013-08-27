class UsersPublicPostsCount < ActiveRecord::Migration
  def up
    add_column :users, :public_posts_count, :integer, default: 0, null: false
    User.all.each do |user|
      user.update_column(:public_posts_count, user.discussion_posts.where(trusted: false).count)
    end
  end

  def down
    remove_column :users, :public_posts_count
  end
end
