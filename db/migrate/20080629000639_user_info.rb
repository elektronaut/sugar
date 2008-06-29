class UserInfo < ActiveRecord::Migration
    def self.up
        add_column :users, :work_safe_urls, :boolean, :null => false, :default => '0'
        add_column :users, :html_disabled, :boolean, :null => false, :default => '0'
        add_column :users, :gamertag, :string
    end

    def self.down
        remove_column :users, :work_safe_urls
        remove_column :users, :html_disabled
        remove_column :users, :gamertag
    end
end
