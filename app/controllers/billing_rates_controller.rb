class BillingRatesController < ApplicationController
  before_filter :find_billing_rate
  before_filter :require_admin_user

  layout "admin_panel"

  helper_method :available_roles

  def create
    @billing_rate = BillingRate.new(params[:billing_rate])
    respond_to do |format|
      if @billing_rate.save
        flash[:notice] = 'Rate was successfully created.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_rate.worklog_task.id }
        format.xml  { render :xml => @billing_rate, :status => :created, :location => @billing_rate }
      else
        flash[:error] = 'Rate did not validate properly!'
        format.html { render :action => "new" }
        format.xml  { render :xml => @billing_rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    worklog_task_id = @billing_rate.worklog_task.id
    respond_to do |format|
      if @billing_rate.destroy
        flash[:notice] = 'Rate was successfully destroyed.'        
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_rate.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Rate could not be destroyed.'
        format.html { redirect_to @billing_rate }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @companies = Company.order("name").all
    if params[:worklog_task]
      @worklog_task = WorklogTask.find(params[:worklog_task][:id])
      @selected_name = @worklog_task.name
      @billing_rates = BillingRate.for_worklog_task(@worklog_task)
    else
      @worklog_task = nil
      @billing_rates = []
      @selected_name = ""
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_rates }
    end
  end

  def edit
  end

  def new
    raise "No worklog task given!" unless params[:worklog_task_id]
    @billing_rate = BillingRate.new
    @billing_rate.worklog_task = WorklogTask.find(params[:worklog_task_id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_rate }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @billing_rate }
    end
  end

  def update
    respond_to do |format|
      if @billing_rate.update_attributes(params[:billing_rate])
        flash[:notice] = 'Rate was successfully updated.'
        format.html { redirect_to :action => :index, "worklog_task[id]" => @billing_rate.worklog_task.id }
        format.xml  { head :ok }
      else
        flash[:error] = 'Rate did not validate properly!'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @billing_rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  private
  
  def available_roles
    Role.order("name ASC").map {|r| [r.name, r.id]}
  end

  def find_billing_rate
    @billing_rate = BillingRate.find(params[:id]) if params[:id]
  end

end
