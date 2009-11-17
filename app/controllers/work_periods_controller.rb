class WorkPeriodsController < ApplicationController
  before_filter :find_work_period
  before_filter :require_user

  # TODO:add before filter for create and update to verify either json style or rails style parameter are complete

  helper_method :available_users, :available_users_exists?
  helper_method :available_worklog_tasks, :available_worklog_tasks_exists?

  WORK_PERIODS_PER_PAGE = 20

  def create
    if params[:work_period].blank?
      @work_period = WorkPeriod.new
      @work_period.user_id = params[:user_id]
      @work_period.worklog_task_id = params[:worklog_task_id]
      @work_period.start = params[:start]
      @work_period.end = params[:end]
      @work_period.comment = params[:comment]
    else
      @work_period = WorkPeriod.new(params[:work_period])
    end

    respond_to do |format|
      if @work_period.save
        flash[:notice] = 'WorkPeriod was successfully created.'
        format.html { redirect_to @work_period }
        format.xml  { render :xml => @work_period, :status => :created, :location => @work_period }
        format.json { render :layout => "none", :json => custom_json(@work_period), :status => :created }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_period.errors, :status => :unprocessable_entity }
        format.json  { render :layout => "none", :json => @work_period.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    deleted_info = Hash[:status => "success", :id => @work_period.id ]
    deleted_id = @work_period.id
    respond_to do |format|
      if @work_period.destroy
        flash[:notice] = 'WorkPeriod was successfully destroyed.'        
        format.html { redirect_to work_periods_path }
        format.xml  { head :ok }
        format.json { render :layout => "none", :json => deleted_info.to_json }
      else
        flash[:error] = 'WorkPeriod could not be destroyed.'
        format.html { redirect_to @work_period }
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def index
    if request.xhr?
      # TODO:add some filtering here.
      user_id = current_user.id
      if params.has_key? "user_id"
        if params["user_id"].to_i != current_user.id and not current_user.admin
          raise "Non-admin users are not allowed to view other users data!"
        else
          user_id = params["user_id"].to_i
        end
      end
      @work_periods = WorkPeriod.find(:all,
                                      :conditions => ["user_id = ? and start > ? and start < ?",
                                                      user_id,
                                                      Time.parse(params["start"]),
                                                      Time.parse(params["end"]) ])
    else
      @work_periods = WorkPeriod.paginate(:page => params[:page], :per_page => WORK_PERIODS_PER_PAGE)
    end
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
    updated_ok = if params[:work_period].blank?
      @work_period.user_id = params[:user_id]
      @work_period.worklog_task_id = params[:worklog_task_id]

      @work_period.start = params[:start]
      @work_period.end = params[:end]
      if params[:comment].chomp == "" or params[:comment] == "null"
        @work_period.comment = nil
      else
        @work_period.comment = params[:comment]
      end
      @work_period.save
    else
      @work_period.update_attributes(params[:work_period])
    end
    respond_to do |format|
      if updated_ok
        flash[:notice] = 'WorkPeriod was successfully updated.'
        format.html { redirect_to @work_period }
        format.xml  { head :ok }
        format.json { render :layout => "none", :json => custom_json(@work_period), :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_period.errors, :status => :unprocessable_entity }
        format.json  { render :layout => "none", :json => @work_period.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def csv_by_company
  end

private

  def custom_json(data)
    if data.respond_to?('collect' )
      result = data.collect do |p|
        next if p.blank?
        Hash[:title => p.worklog_task.name,
             :id => p.id,
             :start => p.start,
             :end => p.end,
             :user_id => p.user_id,
             :worklog_task_id => p.worklog_task_id,
             :color => p.worklog_task.color,
             :company => p.worklog_task.company.name,
             :comment => p.comment,
        ]
      end
    else
      # single period conversion
      p = data
      result = Hash[:title => p.worklog_task.name,
                    :id => p.id,
                    :start => p.start,
                    :end => p.end,
                    :user_id => p.user_id,
                    :worklog_task_id => p.worklog_task_id,
                    :color => p.worklog_task.color,
                    :company => p.worklog_task.company.name,
                    :comment => p.comment
      ]
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