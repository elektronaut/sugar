class CreatePostImages < ActiveRecord::Migration[4.2]
  def change
    create_table :post_images do |t|
      t.string :content_hash
      t.string :content_type
      t.integer :content_length
      t.string :filename
      t.string :colorspace
      t.integer :real_width
      t.integer :real_height
      t.integer :crop_width
      t.integer :crop_height
      t.integer :crop_start_x
      t.integer :crop_start_y
      t.integer :crop_gravity_x
      t.integer :crop_gravity_y
      t.string :original_url, limit: 4096
      t.timestamps null: false

      t.index [:id, :content_hash], unique: true, length: { content_hash: 190 }
      t.index :original_url, length: { original_url: 190 }
    end
  end
end
