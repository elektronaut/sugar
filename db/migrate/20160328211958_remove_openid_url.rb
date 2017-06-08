class RemoveOpenidUrl < ActiveRecord::Migration
  def change
    remove_column :users, :openid_url, :string
  end
end
