module WorklogHelper
  def color_legend_info
    companies = Company.find(:all, :order => 'name ASC')
    worklog_tasks = WorklogTask.find(:all, :order => 'name ASC')

    result = Hash.new
    companies.each {|c| result[ c.name ] = Hash[:color => c.color]}
    worklog_tasks.each do |x|
      if x.color != x.company.color
        result[x.company.name][:odd_tasks] = Hash.new unless result[x.company.name].has_key? :odd_tasks
        result[x.company.name][:odd_tasks][x.name] = x.color
      end
    end
    result.sort
  end

end
