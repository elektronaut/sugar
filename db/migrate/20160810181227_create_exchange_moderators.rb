class CreateExchangeModerators < ActiveRecord::Migration
  def change
    create_table :exchange_moderators do |t|
      t.references :exchange, null: false, index: true
      t.references :user, null: false, index: true
      t.timestamps null: false
    end
  end
end
