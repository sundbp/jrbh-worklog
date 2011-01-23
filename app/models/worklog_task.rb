class WorklogTask < ActiveRecord::Base
  belongs_to :company
  has_many :work_periods, :dependent => :destroy
  has_many :timeplans
  has_many :billing_infos
  has_many :role_allocations
  
  scope :visible_in_user_menus, where(:visible_in_user_menus => true)
  scope :by_name, order("name")
  
  scope :client_tasks, lambda {
    query = nil
  }
  
  scope :internal_tasks, lambda {
    joins(:company).merge(Company.internal_companies)
  }
  
  scope :internal_tasks_work, lambda {
    joins(:company).where("worklog_tasks.name NOT IN (?)", WorklogTask.internal_non_work_tasks_list).merge(Company.internal_companies)
  }
  
  scope :internal_tasks_non_work, lambda {
    joins(:company).where("worklog_tasks.name IN (?)", WorklogTask.internal_non_work_tasks_list).merge(Company.internal_companies)
  }
  
  scope :external_tasks, lambda {
    joins(:company).merge(Company.external_companies)
  }
  
  scope :holidays, joins(:company).where(:name => "Holiday").merge(Company.jrbh)
  
  scope :sickness, joins(:company).where(:name => "Sickness").merge(Company.jrbh)
  
  default_scope joins(:company).order("companies.name").by_name
  
  def self.standard_rate_card
    WorklogTask.joins(:company).where("companies.name = ? AND worklog_tasks.name = ?", "JRBH", "Standard Rate Card").first
  end
  
  def self.internal_non_work_tasks_list
    ["Break", "Lunch", "Sickness", "Holiday"]
  end
  
end
