class CreateXboxInfos < ActiveRecord::Migration
    def self.up
        create_table :xbox_infos do |t|
            t.belongs_to :user
            t.integer    :status, :gamerscore
            t.string     :info, :info2, :status_text, :reputation, :tile_url, :zone
            t.boolean    :valid_xml, :null => false, :default => 0
            t.text       :xml_data
            t.timestamps
        end
        remove_column :users, :xbox_xml
        remove_column :users, :xbox_info
        remove_column :users, :xbox_status
        remove_column :users, :xbox_refreshed_at
        remove_column :users, :xbox_valid
    end

    def self.down
        drop_table :xbox_infos
        add_column :users, :xbox_xml,          :text
        add_column :users, :xbox_info,         :string
        add_column :users, :xbox_status,       :integer
        add_column :users, :xbox_refreshed_at, :datetime
        add_column :users, :xbox_valid,        :boolean, :null => false, :default => 0
    end
end
