class CreateWorkPeriods < ActiveRecord::Migration
  def self.up
    create_table :work_periods do |t|
      t.datetime :start
      t.datetime :end
      t.integer :user_id
      t.integer :worklog_task_id

      t.timestamps
    end
  end

  def self.down
    drop_table :work_periods
  end
end
