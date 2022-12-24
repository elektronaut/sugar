# frozen_string_literal: true

class AddUniquenessIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :conversation_relationships, %i[conversation_id user_id],
              unique: true
    add_index :exchange_moderators, %i[exchange_id user_id], unique: true
    remove_index :users, :username
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :user_mutes, %i[muted_user_id user_id exchange_id], unique: true
  end
end
