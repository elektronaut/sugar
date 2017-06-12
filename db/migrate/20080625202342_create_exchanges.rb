class CreateExchanges < ActiveRecord::Migration[4.2]
  def change
    create_table :exchanges do |t|
      t.string :title
      t.boolean :sticky,  null: false, default: false
      t.boolean :closed,  null: false, default: false
      t.boolean :nsfw,    null: false, default: false
      t.boolean :trusted, null: false, default: false
      t.references :poster, index: true
      t.references :last_poster
      t.references :closer
      t.integer :posts_count, default: 0, null: false
      t.timestamps null: false
      t.datetime :last_post_at
      t.string :type, limit: 100

      t.index :created_at
      t.index :last_post_at
      t.index [:sticky, :last_post_at]
      t.index :sticky
      t.index :trusted
      t.index :type
    end
  end
end
