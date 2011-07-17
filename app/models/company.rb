class Company < ActiveRecord::Base
  has_many :worklog_tasks, :dependent => :destroy
  has_many :work_periods, :through => :worklog_tasks
  
  scope :internal_companies, lambda {
    where(:name => Company.internal_company_list)
  }
  
  scope :external_companies, lambda {
    where("companies.name NOT IN (?)", Company.internal_company_list)
  }
  
  scope :jrbh, where(:name => "JRBH")
  
  def self.internal_company_list
    ["JRBH", "Board IQ", "Revenue IQ", "Strategy IQ"]
  end
  
end
