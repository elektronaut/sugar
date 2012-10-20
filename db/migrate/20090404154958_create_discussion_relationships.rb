class CreateDiscussionRelationships < ActiveRecord::Migration
  def self.up
    create_table :discussion_relationships do |t|
      t.belongs_to :user, :discussion
      t.boolean :participated, :null => false, :default => false
      t.boolean :following,    :null => false, :default => true
      t.boolean :favorite,     :null => false, :default => false
      t.boolean :trusted,      :null => false, :default => false
    end
    add_index :discussion_relationships, :user_id
    add_index :discussion_relationships, :discussion_id
    add_index :discussion_relationships, :participated
    add_index :discussion_relationships, :following
    add_index :discussion_relationships, :favorite
    add_index :discussion_relationships, :trusted
  end

  def self.down
    drop_table :discussion_participations
  end
end
