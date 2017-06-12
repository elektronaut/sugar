class CreateConversationRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :conversation_relationships do |t|
      t.references :user, index: true
      t.references :conversation, index: true
      t.boolean :notifications, default: true, null: false
      t.boolean :new_posts, default: false, null: false
      t.timestamps null: false
    end
  end
end
