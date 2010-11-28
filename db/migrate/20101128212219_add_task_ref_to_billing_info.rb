class AddTaskRefToBillingInfo < ActiveRecord::Migration
  def self.up
    add_column :billing_infos, :worklog_task_id, :integer, :null => false
  end

  def self.down
    remove_column :billing_infos, :worklog_task_id
  end
end
