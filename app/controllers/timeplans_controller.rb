class TimeplansController < ApplicationController
  before_filter :find_timeplan
  before_filter :require_admin_user

  layout "admin_panel"

  helper_method :available_users, :available_allocation_types
  
  def create
    p "-------------------------------------"
    p params
    @timeplan = Timeplan.new(params[:timeplan])
    respond_to do |format|
      if @timeplan.save
        flash[:notice] = 'Timeplan was successfully created.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @timeplan.worklog_task.id }
        format.xml  { render :xml => @timeplan, :status => :created, :location => @timeplan }
      else
        flash[:error] = 'Timeplan did not validate properly!'
        format.html { render :action => "new" }
        format.xml  { render :xml => @timeplan.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    worklog_task_id = @timeplan.worklog_task.id
    respond_to do |format|
      if @timeplan.destroy
        flash[:notice] = 'Timeplan was successfully destroyed.'        
        format.html { redirect_to :action => :index, "worklog_task[id]" => @timeplan.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Timeplan could not be destroyed.'
        format.html { redirect_to @timeplan }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @companies = Company.order("name").all
    if params[:worklog_task]
      @worklog_task = WorklogTask.find(params[:worklog_task][:id])
      @selected_name = @worklog_task.name
      @timeplans = Timeplan.for_worklog_task(@worklog_task)
    else
      @worklog_task = nil
      @timeplans = []
      @selected_name = ""
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @timeplans }
    end
  end

  def edit
  end

  def new
    raise "No worklog task given!" unless params[:worklog_task_id]
    @timeplan = Timeplan.new
    @timeplan.worklog_task = WorklogTask.find(params[:worklog_task_id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @timeplan }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @timeplan }
    end
  end

  def update
    respond_to do |format|
      if @timeplan.update_attributes(params[:timeplan])
        flash[:notice] = 'Timeplan was successfully updated.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @timeplan.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Timeplan did not validate properly!'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @timeplan.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  private
  
  def available_allocation_types
    ["Total", "Monthly"]
  end
  
  def available_users
    User.order("alias").map { |u| [ u.alias, u.id] }
  end

  def find_timeplan
    @timeplan = Timeplan.find(params[:id]) if params[:id]
  end
  
end
