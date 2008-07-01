class CreateDiscussionViews < ActiveRecord::Migration
    def self.up
        create_table :discussion_views do |t|
            t.belongs_to :user, :discussion, :post
            t.integer :post_index, :null => false, :default => 0
        end
        add_index :discussion_views, :user_id,       :name => 'user_id_index'
        add_index :discussion_views, :discussion_id, :name => 'discussion_id_index'
        add_index :discussion_views, :post_id,       :name => 'post_id_index'
    end

    def self.down
        drop_table :discussion_views
    end
end
