class WorkPeriodsController < ApplicationController

  before_filter :find_work_period

  helper_method :available_users, :available_users_exists?
  helper_method :available_worklog_tasks, :available_worklog_tasks_exists?

  WORK_PERIODS_PER_PAGE = 20

  def create
    @work_period = WorkPeriod.new(params[:work_period])
    respond_to do |format|
      if @work_period.save
        flash[:notice] = 'WorkPeriod was successfully created.'
        format.html { redirect_to @work_period }
        format.xml  { render :xml => @work_period, :status => :created, :location => @work_period }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_period.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @work_period.destroy
        flash[:notice] = 'WorkPeriod was successfully destroyed.'        
        format.html { redirect_to work_periods_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'WorkPeriod could not be destroyed.'
        format.html { redirect_to @work_period }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @work_periods = WorkPeriod.paginate(:page => params[:page], :per_page => WORK_PERIODS_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @work_periods }
      format.json { render :layout => "none", :json => custom_json(@work_periods) }
    end
  end

  def edit
  end

  def new
    @work_period = WorkPeriod.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @work_period }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @work_period }
    end
  end

  def update
    respond_to do |format|
      if @work_period.update_attributes(params[:work_period])
        flash[:notice] = 'WorkPeriod was successfully updated.'
        format.html { redirect_to @work_period }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_period.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def custom_json(periods)
    result = periods.collect do |p|
      Hash[:id => p.id, :start => p.start, :end => p.end, :title => p.worklog_task.name]
    end
    result.to_json
  end

  def available_users
    return User.find(:all).collect {|c| [ c.alias, c.id ] }
  end

  def available_users_exists?
    return !available_users.blank?
  end

  def available_worklog_tasks
    return WorklogTask.find(:all).collect {|c| [ c.name, c.id ] }
  end

  def available_worklog_tasks_exists?
    return !available_worklog_tasks.blank?
  end

  def find_work_period
    @work_period = WorkPeriod.find(params[:id]) if params[:id]
  end

end