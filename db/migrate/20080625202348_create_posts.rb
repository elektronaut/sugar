class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.text :body
      t.text :body_html
      t.references :user, index: true
      t.references :exchange, index: true
      t.boolean :trusted, null: false, default: false
      t.boolean :conversation, null: false, default: false
      t.string :format, null: false, default: "markdown"
      t.datetime :edited_at
      t.timestamps null: false

      t.index :conversation
      t.index :created_at
      t.index [:exchange_id, :created_at]
      t.index :trusted
      t.index [:user_id, :conversation]
      t.index [:user_id, :created_at]
    end
  end
end
