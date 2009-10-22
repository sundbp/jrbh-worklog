class WorklogTasksController < ApplicationController
  before_filter :find_worklog_task
  before_filter :require_admin_user

  layout "admin_panel"

  helper_method :available_companies, :available_companies_exists?
          
  WORKLOG_TASKS_PER_PAGE = 20

  def create
    @worklog_task = WorklogTask.new(params[:worklog_task])
    respond_to do |format|
      if @worklog_task.save
        flash[:notice] = 'WorklogTask was successfully created.'
        format.html { redirect_to @worklog_task }
        format.xml  { render :xml => @worklog_task, :status => :created, :location => @worklog_task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @worklog_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @worklog_task.destroy
        flash[:notice] = 'WorklogTask was successfully destroyed.'        
        format.html { redirect_to worklog_tasks_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'WorklogTask could not be destroyed.'
        format.html { redirect_to @worklog_task }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @worklog_tasks = WorklogTask.paginate(:page => params[:page], :per_page => WORKLOG_TASKS_PER_PAGE, :order => 'name ASC')
    respond_to do |format|
      format.html
      format.xml  { render :xml => @worklog_tasks }
    end
  end

  def edit
  end

  def new
    @worklog_task = WorklogTask.new
    c = Company.find(:first)
    @worklog_task.company_id = c.id
    @worklog_task.color = c.color
    respond_to do |format|
      format.html
      format.xml  { render :xml => @worklog_task }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @worklog_task }
    end
  end

  def update
    respond_to do |format|
      if @worklog_task.update_attributes(params[:worklog_task])
        flash[:notice] = 'WorklogTask was successfully updated.'
        format.html { redirect_to @worklog_task }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @worklog_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def company_color
    company_color = Company.find(params[:company_id]).color
    render :partial => 'color_field', :locals => {:company_color => company_color}, :layout => false 
  end

  private

  def available_companies
    return Company.find(:all, :order => 'name ASC').map {|c| [ c.name, c.id ] }
  end

  def available_companies_exists?
    return !available_companies.blank?
  end

  def find_worklog_task
    @worklog_task = WorklogTask.find(params[:id]) if params[:id]
  end

end