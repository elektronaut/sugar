class CreateDelayedJobs < ActiveRecord::Migration[4.2]
  def change
    create_table :delayed_jobs do |t|
      t.integer :priority, default: 0
      t.integer :attempts, default: 0
      t.text :handler
      t.string :last_error
      t.datetime :run_at
      t.datetime :locked_at
      t.datetime :failed_at
      t.string :locked_by
      t.timestamps null: false
    end
  end
end
