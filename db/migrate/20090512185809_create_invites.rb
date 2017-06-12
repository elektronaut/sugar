class CreateInvites < ActiveRecord::Migration[4.2]
  def change
    create_table :invites do |t|
      t.references :user
      t.string :email
      t.string :token
      t.text :message
      t.datetime :expires_at
      t.timestamps null: false
    end
  end
end
