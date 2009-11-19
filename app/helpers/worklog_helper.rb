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

  class WorklogTaskGroup
    attr_reader :group_name, :options
    def initialize(name)
      @group_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end

    def <=>(other)
      return @group_name <=> other.group_name
    end
  end

  WorklogTaskGroupOption = Struct.new(:id, :name)

  def task_groups_options
    result = Hash.new
    worklog_tasks = WorklogTask.visible_in_user_menus
    worklog_tasks.each do |t|
      result[t.company.name] = WorklogTaskGroup.new(t.company.name) unless result.has_key? t.company.name
      result[t.company.name] << WorklogTaskGroupOption.new(t.id, t.name)
    end

    result.values.sort
  end
end
