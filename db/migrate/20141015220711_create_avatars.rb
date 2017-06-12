class CreateAvatars < ActiveRecord::Migration[4.2]
  def change
    create_table :avatars do |t|
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
      t.timestamps null: false
    end
  end
end
