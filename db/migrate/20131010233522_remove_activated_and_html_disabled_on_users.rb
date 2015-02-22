class RemoveActivatedAndHtmlDisabledOnUsers < ActiveRecord::Migration
  def up
    remove_column :users, :activated
    remove_column :users, :html_disabled
    remove_column :users, :application
  end

  def down
    add_column :users, :activated, :boolean, default: false, null: false
    add_column :users, :html_disabled, :boolean, default: false, null: false
    add_column :users, :application, :text
  end
end
