# frozen_string_literal: true

class AddStatusToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :status, :integer, null: false, default: 0

    User.where.not(banned_until: nil).update_all(status: :hiatus)
    User.where(banned: true).update_all(status: :banned)
    User.where(memorialized: true).update_all(status: :memorialized)

    remove_column :users, :memorialized
    remove_column :users, :banned
  end

  def down
    add_column :users, :banned, :boolean, null: false, default: false
    add_column :users, :memorialized, :boolean, null: false, default: false
    User.reset_column_information

    User.all.each do |user|
      case user.status
      when :memorialized
        user.update(memorialized: true)
      when :banned, :inactive
        user.update(banned: true)
      end
    end

    remove_column :users, :status
  end
end
