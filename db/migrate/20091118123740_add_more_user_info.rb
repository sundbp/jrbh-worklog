class AddMoreUserInfo < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :email, :string
    add_column :users, :active_employee, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :email
    remove_column :users, :active_employee
  end
end
