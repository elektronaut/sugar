# frozen_string_literal: true

class DropPasswordResetTokens < ActiveRecord::Migration[7.0]
  def up
    drop_table :password_reset_tokens
  end

  def down
    create_table :password_reset_tokens do |t|
      t.references :user, index: true
      t.string :token
      t.datetime :expires_at
      t.timestamps null: false
    end
  end
end
