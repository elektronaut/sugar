class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, limit: 100
      t.string :realname, :email, :hashed_password, :location, :gamertag
      t.string :avatar_url, :stylesheet_url
      t.text :description
      t.boolean :banned, :activated, :admin, null: false, default: false
      t.boolean :trusted, :user_admin, :moderator, null: false, default: false
      t.boolean :work_safe_urls, :html_disabled, null: false, default: false
      t.boolean :notify_on_message, null: false, default: true
      t.boolean :keyboard_navigation, null: false, default: true
      t.datetime :last_active
      t.date :birthday
      t.integer :posts_count, :discussions_count, default: 0, null: false
      t.belongs_to :inviter
      t.string :msn, :gtalk, :aim, :twitter, :flickr, :last_fm, :website
      t.string :openid_url
      t.float :longitude, :latitude
      t.text :application
      t.timestamps
    end
    add_index :users, :username, name: "username_index"
    add_index :users, :last_active, name: "last_active_index"
  end

  def self.down
    drop_table :users
  end
end
