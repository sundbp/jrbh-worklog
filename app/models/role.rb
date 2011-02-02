class Role < ActiveRecord::Base
  has_many :role_allocations
  
  def self.uncharged_role
    query = Role.where(:name => "Uncharged Role")
    raise "Uncharged Role not defined!" if query.size == 0
    query.first
  end
  
end
