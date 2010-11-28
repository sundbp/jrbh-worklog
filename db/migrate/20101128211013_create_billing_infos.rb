class CreateBillingInfos < ActiveRecord::Migration
  def self.up
    create_table :billing_infos do |t|
      t.date :start_date, :null => false
      t.date :end_date, :null => false
      t.float :invoice_amount, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_infos
  end
end
