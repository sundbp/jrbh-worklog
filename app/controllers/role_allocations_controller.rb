class RoleAllocationsController < ApplicationController
  before_filter :find_role_allocation
  before_filter :require_admin_user

  layout "admin_panel"

  helper_method :available_users

  def create
    @role_allocation = RoleAllocation.new(params[:role_allocation])
    respond_to do |format|
      if @role_allocation.save
        flash[:notice] = 'Role allocation was successfully created.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @role_allocation.worklog_task.id }
        format.xml  { render :xml => @role_allocation, :status => :created, :location => @role_allocation }
      else
        flash[:error] = 'Role allocation did not validate properly!'
        format.html { render :action => "new" }
        format.xml  { render :xml => @role_allocation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    worklog_task_id = @role_allocation.worklog_task.id
    respond_to do |format|
      if @role_allocation.destroy
        flash[:notice] = 'Role allocation was successfully destroyed.'        
        format.html { redirect_to :action => :index, "worklog_task[id]" => @role_allocation.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Role allocation could not be destroyed.'
        format.html { redirect_to @role_allocation }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @companies = Company.order("name").all
    if params[:worklog_task]
      @worklog_task = WorklogTask.find(params[:worklog_task][:id])
      @selected_name = @worklog_task.name
      @role_allocations = RoleAllocation.for_worklog_task(@worklog_task)
    else
      @worklog_task = nil
      @role_allocations = []
      @selected_name = ""
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @role_allocations }
    end
  end

  def edit
  end

  def new
    raise "No worklog task given!" unless params[:worklog_task_id]
    @role_allocation = RoleAllocation.new
    @role_allocation.worklog_task = WorklogTask.find(params[:worklog_task_id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @role_allocation }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @role_allocation }
    end
  end

  def update
    respond_to do |format|
      if @role_allocation.update_attributes(params[:role_allocation])
        flash[:notice] = 'Role allocation was successfully updated.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @role_allocation.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Role allocation did not validate properly!'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role_allocation.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  private
  
  def available_users
    User.order("alias").map { |u| [ u.alias, u.id] }
  end

  def find_role_allocation
    @role_allocation = RoleAllocation.find(params[:id]) if params[:id]
  end

end
