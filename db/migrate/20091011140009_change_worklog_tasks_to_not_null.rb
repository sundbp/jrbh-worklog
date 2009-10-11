class ChangeWorklogTasksToNotNull < ActiveRecord::Migration
  def self.up
    change_column :worklog_tasks, :company_id, :integer, :null => false
    change_column :worklog_tasks, :name, :string, :null => false
  end

  def self.down
    change_column :worklog_tasks, :company_id, :integer, :null => true
    change_column :worklog_tasks, :name, :string, :null => true
  end
end
