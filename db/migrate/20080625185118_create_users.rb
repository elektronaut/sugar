class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table :users do |t|
            t.string     :username, :realname, :email, :hashed_password, :location
            t.string     :stylesheet_url
            t.text       :description
            t.boolean    :banned, :activated, :admin, :trusted, :user_admin, :moderator, :null => false, :default => '0'
            t.datetime   :last_active
            t.date       :birthday
            t.integer    :posts_count, :discussions_count, :default => 0, :null => false
            t.belongs_to :inviter
            t.timestamps
        end
        add_index :users, :username,    :name => 'username_index'
        add_index :users, :last_active, :name => 'last_active_index'
    end

    def self.down
        drop_table :users
    end
end
