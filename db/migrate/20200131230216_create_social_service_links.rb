class CreateSocialServiceLinks < ActiveRecord::Migration[5.2]
  def service_mapping
    { aim: "AIM",
      battlenet: "Battle.net",
      flickr: "Flickr",
      gamertag: "Xbox Live",
      gtalk: "Google Talk",
      instagram: "Instagram",
      last_fm: "Last.fm",
      msn: "Microsoft Messenger",
      nintendo: "Nintendo Network ID",
      nintendo_switch: "Nintendo Switch",
      sony: "PlayStation",
      steam: "Steam",
      twitter: "Twitter",
      facebook_uid: "Facebook" }
  end

  def up
    create_table :social_service_links do |t|
      t.references :user
      t.references :social_service
      t.string :username
      t.string :url
      t.timestamps
    end

    User.find_each do |u|
      service_mapping.each do |attr, name|
        next unless u.send("#{attr}?")

        u.social_service_links.create(
          social_service: SocialService.find_by(name: name),
          username: u.send(attr)
        )
      end
    end

    remove_column :users, :aim
    remove_column :users, :battlenet
    remove_column :users, :flickr
    remove_column :users, :gamertag
    remove_column :users, :gtalk
    remove_column :users, :instagram
    remove_column :users, :last_fm
    remove_column :users, :msn
    remove_column :users, :nintendo
    remove_column :users, :nintendo_switch
    remove_column :users, :sony
    remove_column :users, :steam
    remove_column :users, :twitter
  end

  def down
    add_column :users, :aim, :string
    add_column :users, :battlenet, :string
    add_column :users, :flickr, :string
    add_column :users, :gamertag, :string
    add_column :users, :gtalk, :string
    add_column :users, :instagram, :string
    add_column :users, :last_fm, :string
    add_column :users, :msn, :string
    add_column :users, :nintendo, :string
    add_column :users, :nintendo_switch, :string
    add_column :users, :sony, :string
    add_column :users, :steam, :string
    add_column :users, :twitter, :string

    User.reset_column_information

    User.find_each do |u|
      attrs = {}
      u.social_service_links.each do |l|
        attr = service_mapping.invert[l.social_service.name]
        attrs[attr] = l.username if attr
      end
      u.update_columns(attrs) if attrs.any?
    end

    drop_table :social_service_links
  end
end
