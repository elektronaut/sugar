# frozen_string_literal: true

class CreateUserLinks < ActiveRecord::Migration[7.0]
  def services
    { aim: { name: "AIM" },
      battlenet: { name: "Battle.net BattleTag" },
      flickr: { name: "Flickr",
                pattern: "https://www.flickr.com/photos/%username%/" },
      gamertag: { name: "Xbox Live",
                  pattern: "https://account.xbox.com/en-us/profile" \
                           "?gamertag=%username%" },
      gtalk: { name: "Google Chat" },
      instagram: { name: "Instagram",
                   pattern: "https://www.instagram.com/%username%/" },
      last_fm: { name: "Last.fm",
                 pattern: "https://www.last.fm/user/%username%" },
      msn: { name: "Microsoft Messenger" },
      nintendo: { name: "Nintendo Network ID" },
      nintendo_switch: { name: "Nintendo Switch Friend Code" },
      sony: { name: "PlayStation",
              pattern: "https://my.playstation.com/profile/%username%" },
      steam: { name: "Steam",
               pattern: "https://steamcommunity.com/id/%username%" },
      twitter: { name: "Twitter", pattern: "https://twitter.com/%username%" },
      website: { name: "Website", pattern: "%username%" } }
  end

  def up
    create_table :user_links do |t|
      t.references :user
      t.string :label
      t.string :name
      t.text :url
      t.integer :position
      t.timestamps
      t.index :label
    end

    User.all.each do |user|
      services.each do |attr, service|
        name = user.send(attr)
        next if name.blank?

        url = service[:pattern].gsub("%username%", name) if service[:pattern]
        user.user_links.create(label: service[:name], name: name, url: url)
      end

      next unless user.facebook_uid?

      UserLink.create(
        label: "Facebook",
        url: "https://www.facebook.com/%username%".gsub("%username%",
                                                        user.facebook_uid)
      )
    end

    change_table :users, bulk: true do |t|
      services.each_key { |s| t.remove s }
    end
  end

  def down
    change_table :users, bulk: true do |t|
      services.each_key { |s| t.string s }
    end

    drop_table :user_links
  end
end
