class AddPreferredFormatToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferred_format, :string
  end
end
