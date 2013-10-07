class AddFormatToPost < ActiveRecord::Migration
  def change
    add_column :posts, :format, :string, default: "markdown", null: false
  end
end
