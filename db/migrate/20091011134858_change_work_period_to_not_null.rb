class ChangeWorkPeriodToNotNull < ActiveRecord::Migration
  def self.up
    change_column :work_periods, :start, :datetime, :null => false
    change_column :work_periods, :end, :datetime, :null => false
    change_column :work_periods, :user_id, :integer, :null => false
    change_column :work_periods, :worklog_task_id, :integer, :null => false
  end

  def self.down
    change_column :work_periods, :start, :datetime, :null => true
    change_column :work_periods, :end, :datetime, :null => true
    change_column :work_periods, :user_id, :integer, :null => true
    change_column :work_periods, :worklog_task_id, :integer, :null => true
  end
end
