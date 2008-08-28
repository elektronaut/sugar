class TrustedPostFields < ActiveRecord::Migration
    def self.up
        add_column :posts, :trusted, :boolean, :null => false, :default => '0'
        Discussion.find(:all, :conditions => 'trusted = 1').each do |discussion|
            Post.update_all("trusted = 1", "discussion_id = #{discussion.id}")
        end
        add_index :posts, :trusted, :name => 'trusted_index'
        add_index :discussions, :trusted, :name => 'trusted_index'
    end

    def self.down
        remove_index :posts, :name => 'trusted_index'
        remove_index :discussions, :name => 'trusted_index'
        remove_column :posts, :trusted
    end
end
