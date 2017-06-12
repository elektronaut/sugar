class CreateDoorkeeperTables < ActiveRecord::Migration[4.2]
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.string :redirect_uri, null: false
      t.timestamps null: false

      # t.index :uid, unique: true
    end

    create_table :oauth_access_grants do |t|
      t.integer :resource_owner_id, null: false
      t.integer :application_id, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.string :redirect_uri, null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :scopes

      # t.index :token, unique: true
    end

    create_table :oauth_access_tokens do |t|
      t.integer :resource_owner_id
      t.integer :application_id, null: false
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string :scopes

      # t.index :token, unique: true
      t.index :resource_owner_id
      # t.index :refresh_token, unique: true
    end
  end
end
