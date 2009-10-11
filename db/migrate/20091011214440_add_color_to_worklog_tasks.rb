class AddColorToWorklogTasks < ActiveRecord::Migration
  def self.up
    add_column :worklog_tasks, :color, :string, :null => false,  :default => "#68a1e5"
  end

  def self.down
    remove_column :worklog_tasks, :color
  end
end
