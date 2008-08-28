class TrustedPostFields < ActiveRecord::Migration
    def self.up
        add_column :posts, :trusted, :boolean, :null => false, :default => '0'
        Discussion.find(:all, :conditions => 'trusted = 1').each do |discussion|
            Post.update_all("trusted = 1", "discussion_id = #{discussion.id}")
        end
    end

    def self.down
        remove_column :posts, :trusted
    end
end
