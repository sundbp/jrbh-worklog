class CreateWorklogTasks < ActiveRecord::Migration
  def self.up
    create_table :worklog_tasks do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
  end

  def self.down
    drop_table :worklog_tasks
  end
end
