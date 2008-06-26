class CreateDiscussions < ActiveRecord::Migration
    def self.up
        create_table :discussions do |t|
            t.string :title
            t.boolean :sticky, :closed, :null => false, :default => '0'
            t.belongs_to :poster, :last_poster, :category
            t.integer :posts_count, :default => 0
            t.timestamps
            t.datetime :last_post_at
        end
        add_index :discussions, :poster_id, :name => 'discussion_id_index'
        add_index :discussions, :category_id, :name => 'category_id_index'
        add_index :discussions, :created_at, :name => 'created_at_index'
        add_index :discussions, :created_at, :name => 'last_post_at_index'
    end

    def self.down
        drop_table :discussions
    end
end
