# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :name
      t.jsonb :value
      t.timestamps
      t.index :name, unique: true
    end
  end
end
