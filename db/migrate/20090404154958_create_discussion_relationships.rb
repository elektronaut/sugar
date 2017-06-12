class CreateDiscussionRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :discussion_relationships do |t|
      t.references :user, index: true
      t.belongs_to :discussion, index: true
      t.boolean :participated, null: false, default: false
      t.boolean :following,    null: false, default: true
      t.boolean :favorite,     null: false, default: false
      t.boolean :trusted,      null: false, default: false
      t.boolean :hidden,       null: false, default: false

      t.index :participated
      t.index :following
      t.index :favorite
      t.index :trusted
      t.index :hidden
    end
  end
end
