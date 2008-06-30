class UserFields < ActiveRecord::Migration
    def self.up
        add_column :users, :msn, :string
        add_column :users, :gtalk, :string
        add_column :users, :aim, :string
        add_column :users, :twitter, :string
        add_column :users, :flickr, :string
        add_column :users, :last_fm, :string
        add_column :users, :website, :string
    end

    def self.down
        drop_column :users, :msn
        drop_column :users, :gtalk
        drop_column :users, :aim
        drop_column :users, :twitter
        drop_column :users, :flickr
        drop_column :users, :last_fm
        drop_column :users, :website
    end
end
