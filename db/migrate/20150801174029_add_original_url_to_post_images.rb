class AddOriginalUrlToPostImages < ActiveRecord::Migration
  def change
    add_column :post_images, :original_url, :string, limit: 4096
    add_index(
      :post_images,
      [:id, :content_hash],
      unique: true,
      length: { content_hash: 190 }
    )
    add_index :post_images, :original_url, length: { original_url: 190 }
  end
end
