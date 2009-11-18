class AddIndexToWorkPeriods < ActiveRecord::Migration
  def self.up
    add_index :work_periods, [:user_id, :start, :end], :unique => true
  end

  def self.down
  end
end
