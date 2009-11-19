class WorklogTask < ActiveRecord::Base
  belongs_to :company
  has_many :work_periods, :dependent => :destroy

  named_scope :visible_in_user_menus, :conditions => {:visible_in_user_menus => true}
  named_scope :by_company, :joins => "as worklog_tasks inner join companies on companies.id = worklog_tasks.company_id", :order => "companies.name"
  named_scope :by_name, :order => "worklog_tasks.name"
end
