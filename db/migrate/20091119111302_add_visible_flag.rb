class AddVisibleFlag < ActiveRecord::Migration
  def self.up
    add_column :worklog_tasks, :visible_in_user_menus, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :worklog_tasks, :visible_in_user_menus
  end
end
