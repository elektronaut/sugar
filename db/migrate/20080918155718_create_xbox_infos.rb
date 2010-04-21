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
    end

    def self.down
        drop_table :xbox_infos
    end
end
