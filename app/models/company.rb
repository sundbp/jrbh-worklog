class Company < ActiveRecord::Base
  has_many :worklog_tasks, :dependent => :destroy
  has_many :work_periods, :through => :worklog_tasks
  
  def self.jrbh_companies
    [ Company.where(:name => "JRBH").first,
      Company.where(:name => "JRBH Board Consulting").first,
      Company.where(:name => "JRBH Brand Commercialisation").first
    ]
  end
  
end
