class ChangeCompaniesToNotNull < ActiveRecord::Migration
  def self.up
    change_column :companies, :name, :string, :null => false
  end

  def self.down
    change_column :companies, :name, :string, :null => true
  end
end
