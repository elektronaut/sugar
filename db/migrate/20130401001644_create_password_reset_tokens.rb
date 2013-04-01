class CreatePasswordResetTokens < ActiveRecord::Migration
  def change
    create_table :password_reset_tokens do |t|
      t.belongs_to :user
      t.string :token
      t.datetime :expires_at
      t.timestamps
    end
    add_index :password_reset_tokens, :user_id
  end
end
