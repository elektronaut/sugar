class RemoveOpenidUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :openid_url, :string
  end
end
