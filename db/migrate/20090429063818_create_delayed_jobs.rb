class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs, force: true do |table|
      table.integer :priority, default: 0
      table.integer :attempts, default: 0
      table.text :handler
      table.string :last_error
      table.datetime :run_at
      table.datetime :locked_at
      table.datetime :failed_at
      table.string :locked_by
      table.timestamps
    end
  end

  def self.down
    drop_table :delayed_jobs
  end
end
