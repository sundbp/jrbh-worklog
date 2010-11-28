class BillingInfosController < ApplicationController
  before_filter :find_billing_info
  before_filter :require_admin_user

  layout "admin_panel"

  def create
    @billing_info = BillingInfo.new(params[:billing_info])
    respond_to do |format|
      if @billing_info.save
        flash[:notice] = 'BillingInfo was successfully created.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_info.worklog_task.id }
        format.xml  { render :xml => @billing_info, :status => :created, :location => @billing_info }
      else
        flash[:error] = 'BillingInfo did not validate properly!'
        format.html { render :action => "new" }
        format.xml  { render :xml => @billing_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    worklog_task_id = @billing_info.worklog_task.id
    respond_to do |format|
      if @billing_info.destroy
        flash[:notice] = 'BillingInfo was successfully destroyed.'        
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_info.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'BillingInfo could not be destroyed.'
        format.html { redirect_to @billing_info }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @companies = Company.order("name").all
    if params[:worklog_task]
      @worklog_task = WorklogTask.find(params[:worklog_task][:id])
      @selected_name = @worklog_task.name
      @billing_infos = BillingInfo.for_worklog_task(@worklog_task)
    else
      @worklog_task = nil
      @billing_infos = []
      @selected_name = ""
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_infos }
    end
  end

  def edit
  end

  def new
    raise "No worklog task given!" unless params[:worklog_task_id]
    @billing_info = BillingInfo.new
    @billing_info.worklog_task = WorklogTask.find(params[:worklog_task_id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_info }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_info }
    end
  end

  def update
    respond_to do |format|
      if @billing_info.update_attributes(params[:billing_info])
        flash[:notice] = 'BillingInfo was successfully updated.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_info.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'BillingInfo did not validate properly!'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @billing_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  private
  
  def find_billing_info
    @billing_info = BillingInfo.find(params[:id]) if params[:id]
  end
  
end
