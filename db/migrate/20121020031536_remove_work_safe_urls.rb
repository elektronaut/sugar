class RemoveWorkSafeUrls < ActiveRecord::Migration
  def up
    remove_column :users, :work_safe_urls
  end

  def down
    add_column :users, :work_safe_urls, :boolean, :null => false, :default => false
  end
end
