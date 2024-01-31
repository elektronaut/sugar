# frozen_string_literal: true

class ConvertToHasSecurePassword < ActiveRecord::Migration[7.1]
  def up
    enable_extension "citext"

    rename_column :users, :hashed_password, :password_digest
    change_column :users, :email, :citext
    change_column :invites, :email, :citext
    add_index :invites, :email, unique: true, name: "index_invites_on_email"
  end

  def down
    rename_column :users, :password_digest, :hashed_password
    change_column :users, :email, :string
    change_column :invites, :email, :string
    remove_index :invites, name: "index_invites_on_email"
  end
end
