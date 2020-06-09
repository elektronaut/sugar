# frozen_string_literal: true

class CreateUserMutes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_mutes do |t|
      t.references :user
      t.references :muted_user
      t.references :exchange
      t.timestamps
    end
  end
end
