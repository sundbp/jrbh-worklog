class WorklogTask < ActiveRecord::Base
  belongs_to :company
  has_many :work_periods, :dependent => :destroy
  has_many :timeplans
  has_many :billing_infos
  has_many :role_allocations
  
  scope :visible_in_user_menus, where(:visible_in_user_menus => true)
  scope :by_name, order("name")
  
  default_scope joins(:company).order("companies.name").by_name
  
  def self.standard_rate_card
    WorklogTask.joins(:company).where("companies.name = ? AND worklog_tasks.name = ?", "JRBH", "Standard Rate Card").first
  end
end
