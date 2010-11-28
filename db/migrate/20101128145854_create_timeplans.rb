class CreateTimeplans < ActiveRecord::Migration
  def self.up
    create_table :timeplans do |t|
      t.date :start_date
      t.date :end_date
      t.string :allocation_type
      t.integer :time_allocation

      t.references :worklog_task
      t.references :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :timeplans
  end
end
