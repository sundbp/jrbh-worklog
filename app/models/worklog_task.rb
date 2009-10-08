class WorklogTask < ActiveRecord::Base
  belongs_to :company
  has_many :work_periods
end
