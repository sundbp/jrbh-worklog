class WorklogTask < ActiveRecord::Base
  belongs_to :company
  has_many :work_periods, :dependent => :destroy
  has_many :timeplans
  has_many :billing_infos
  
  scope :visible_in_user_menus, where(:visible_in_user_menus => true)
  scope :by_name, order("name")
  
  default_scope joins(:company).order("companies.name").by_name #, worklog_tasks.name") # "as worklog_tasks inner join companies on companies.id = worklog_tasks.company_id",
                 #:order => "companies.name, worklog_tasks.name"
end
