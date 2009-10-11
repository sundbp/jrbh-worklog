class AddColorToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :color, :string, :null => false, :default => "#68a1e5"
  end

  def self.down
    remove_column :companies, :color
  end
end
