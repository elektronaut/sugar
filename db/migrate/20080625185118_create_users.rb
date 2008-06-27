class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table :users do |t|
            t.string     :username, :realname, :email, :hashed_password, :location
            t.text       :description
            t.boolean    :banned, :activated, :admin, :null => false, :default => '0'
            t.datetime   :last_active
            t.date       :birthday
            t.integer    :posts_count, :discussions_count, :default => 0, :null => false
            t.belongs_to :inviter
            t.timestamps
        end
        add_index :users, :username, :name => 'username_index'
    end

    def self.down
        drop_table :users
    end
end
