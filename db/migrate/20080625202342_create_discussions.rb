class CreateDiscussions < ActiveRecord::Migration
    def self.up
        create_table :discussions do |t|
            t.string :title
            t.boolean :sticky, :closed, :nsfw, :trusted, :delta, :null => false, :default => '0'
            t.belongs_to :poster, :last_poster, :category, :closer
            t.integer :posts_count, :default => 0, :null => false
            t.timestamps
            t.datetime :last_post_at
        end
        add_index :discussions, :poster_id, :name => 'poster_id_index'
        add_index :discussions, :category_id, :name => 'category_id_index'
        add_index :discussions, :created_at, :name => 'created_at_index'
        add_index :discussions, :last_post_at, :name => 'last_post_at_index'
        add_index :discussions, :sticky, :name => 'sticky_index'
        add_index :discussions, :trusted, :name => 'trusted_index'
		add_index :discussions, :delta, :name => 'delta_index'
		add_index :discussions, [:sticky, :last_post_at]
    end

    def self.down
        drop_table :discussions
    end
end
