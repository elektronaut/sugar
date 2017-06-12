class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :username, limit: 100
      t.string :realname
      t.string :email
      t.string :hashed_password
      t.string :location
      t.string :gamertag
      t.string :stylesheet_url
      t.text :description
      t.boolean :banned, null: false, default: false
      t.boolean :admin, null: false, default: false
      t.boolean :trusted, null: false, default: false
      t.boolean :user_admin, null: false, default: false
      t.boolean :moderator, null: false, default: false
      t.boolean :notify_on_message, null: false, default: true
      t.datetime :last_active
      t.date :birthday
      t.integer :posts_count, default: 0, null: false
      t.references :inviter
      t.string :msn
      t.string :gtalk
      t.string :aim
      t.string :twitter
      t.string :flickr
      t.string :last_fm
      t.string :website
      t.string :openid_url
      t.float :longitude
      t.float :latitude
      t.timestamps null: false
      t.integer :available_invites, null: false, default: 0
      t.string :facebook_uid
      t.integer :participated_count, null: false, default: 0
      t.integer :favorites_count, null: false, default: 0
      t.integer :following_count, null: false, default: 0
      t.string :time_zone
      t.datetime :banned_until
      t.string :mobile_stylesheet_url
      t.string :theme
      t.string :mobile_theme
      t.string :instagram
      t.string :persistence_token
      t.integer :public_posts_count, null: false, default: 0
      t.integer :hidden_count, null: false, default: 0
      t.string :preferred_format
      t.string :sony
      t.integer :avatar_id
      t.text :previous_usernames
      t.string :nintendo
      t.string :steam
      t.string :battlenet

      t.index :last_active
      t.index :username
    end
  end
end
