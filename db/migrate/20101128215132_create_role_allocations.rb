class CreateRoleAllocations < ActiveRecord::Migration
  def self.up
    create_table :role_allocations do |t|
      t.date :start_date, :null => false
      t.date :end_date
      t.string :role, :null => false

      t.references :worklog_task, :null => false
      t.references :user, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :role_allocations
  end
end
