class ChangeTimeplanColumns < ActiveRecord::Migration
  def self.up
    change_column :timeplans, :start_date, :date, :null => false
    change_column :timeplans, :time_allocation, :float, :null => false
  end

  def self.down
    change_column :timeplans, :start_date, :date, :null => true
    change_column :timeplans, :time_allocation, :integer
  end
end
