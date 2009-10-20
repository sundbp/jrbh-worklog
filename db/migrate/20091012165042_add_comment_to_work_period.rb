class AddCommentToWorkPeriod < ActiveRecord::Migration
  def self.up
    add_column :work_periods, :comment, :string
  end

  def self.down
    remove_column :work_periods, :comment
  end
end
