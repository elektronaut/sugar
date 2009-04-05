class UserXboxInfo < ActiveRecord::Migration
    def self.up
        add_column :users, :xbox_xml,          :text
        add_column :users, :xbox_info,         :string
        add_column :users, :xbox_status,       :integer
        add_column :users, :xbox_refreshed_at, :datetime
        add_column :users, :xbox_valid,        :boolean, :null => false, :default => 0
    end

    def self.down
        remove_column :users, :xbox_xml
        remove_column :users, :xbox_info
        remove_column :users, :xbox_status
        remove_column :users, :xbox_refreshed_at
        remove_column :users, :xbox_valid
    end
end
