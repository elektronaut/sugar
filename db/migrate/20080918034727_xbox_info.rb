class XboxInfo < ActiveRecord::Migration
    def self.up
        add_column :users, :xbox_xml,          :text
        add_column :users, :xbox_info,         :string
        add_column :users, :xbox_status,       :integer
        add_column :users, :xbox_refreshed_at, :datetime
    end

    def self.down
        remove_column :users, :xbox_xml
        remove_column :users, :xbox_info
        remove_column :users, :xbox_status
        remove_column :users, :xbox_refreshed_at
    end
end
