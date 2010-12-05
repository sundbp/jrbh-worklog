class CreateBillingRates < ActiveRecord::Migration
  def self.up
    create_table :billing_rates do |t|
      t.date :start_date
      t.date :end_date
      t.float :rate

      t.references :worklog_task, :null => false
      t.references :role, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_rates
  end
end
