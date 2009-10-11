class ChangeUsersToNotNull < ActiveRecord::Migration
  def self.up
    change_column :users, :login, :string, :null => false
    change_column :users, :alias, :string, :null => false
    change_column :users, :admin, :boolean, :null => false
  end

  def self.down
    change_column :users, :login, :string, :null => true
    change_column :users, :alias, :string, :null => true
    change_column :users, :admin, :boolean, :null => true
  end
end
