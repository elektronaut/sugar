# frozen_string_literal: true

class RemoveDoorkeeperTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.string :redirect_uri, null: false
      t.timestamps null: false
    end

    drop_table :oauth_access_grants do |t|
      t.integer :resource_owner_id, null: false
      t.integer :application_id, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.string :redirect_uri, null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :scopes
    end

    drop_table :oauth_access_tokens do |t|
      t.integer :resource_owner_id
      t.integer :application_id, null: false
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string :scopes
      t.index :resource_owner_id
    end
  end
end
