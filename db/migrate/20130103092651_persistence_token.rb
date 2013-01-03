class PersistenceToken < ActiveRecord::Migration
  def up
    add_column :users, :persistence_token, :string
    User.all.each do |user|
      user.persistence_token ||= User.generate_token
      user.save
    end
  end

  def down
    remove_column :users, :persistence_token
  end
end
