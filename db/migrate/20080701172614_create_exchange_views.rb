# frozen_string_literal: true

class CreateExchangeViews < ActiveRecord::Migration[4.2]
  def change
    create_table :exchange_views do |t|
      t.references :user, index: true
      t.references :exchange, index: true
      t.references :post, index: true
      t.integer :post_index, null: false, default: 0
      t.index %i[user_id exchange_id]
    end
  end
end
