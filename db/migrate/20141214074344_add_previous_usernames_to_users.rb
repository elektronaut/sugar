class AddPreviousUsernamesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :previous_usernames, :text
  end
end
