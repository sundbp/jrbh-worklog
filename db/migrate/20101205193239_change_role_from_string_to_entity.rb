class ChangeRoleFromStringToEntity < ActiveRecord::Migration
  def self.up
    add_column :role_allocations, :role_id, :integer, :null => false
    remove_column :role_allocations, :role
  end

  def self.down
    remove_column :role_allocations, :role_id
    add_column :role_allocation, :role, :string, :null => false
  end
end
