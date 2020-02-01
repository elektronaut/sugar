class CreateSocialServices < ActiveRecord::Migration[5.2]
  def change
    create_table :social_services do |t|
      t.string :name, index: true
      t.string :label, default: "Username"
      t.string :url_pattern
      t.boolean :custom_url, null: false, default: false
      t.boolean :enabled, null: false, default: true
    end

    reversible do |dir|
      dir.up do
        [
          { name: "Xbox Live",
            url_pattern: "https://account.xbox.com/en-us/profile" \
                         "?gamertag=%username%" },
          { name: "PlayStation",
            url_pattern: "https://my.playstation.com/profile/%username%" },
          { name: "Nintendo Network ID", label: "ID" },
          { name: "Nintendo Switch", label: "Friend Code" },
          { name: "Steam",
            url_pattern: "https://steamcommunity.com/id/%username%" },
          { name: "Battle.net", label: "BattleTag" },
          { name: "Instagram",
            url_pattern: "https://www.instagram.com/%username%/" },
          { name: "Flickr",
            url_pattern: "https://www.flickr.com/photos/%username%/" },
          { name: "Twitter",
            url_pattern: "https://twitter.com/%username%" },
          { name: "Last.fm",
            url_pattern: "https://www.last.fm/user/%username%" },
          { name: "Facebook",
            url_pattern: "https://www.facebook.com/%username%",
            custom_url: true },

          { name: "Google Talk", enabled: false },
          { name: "Microsoft Messenger", enabled: false },
          { name: "AIM", enabled: false }
        ].each do |attrs|
          SocialService.create(attrs)
        end
      end
    end
  end
end
