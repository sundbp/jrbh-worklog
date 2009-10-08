class CompaniesController < ApplicationController
  before_filter :find_company
  before_filter :require_admin_user

  layout "admin_panel"

  COMPANIES_PER_PAGE = 20

  def create
    @company = Company.new(params[:company])
    respond_to do |format|
      if @company.save
        flash[:notice] = 'Company was successfully created.'
        format.html { redirect_to @company }
        format.xml  { render :xml => @company, :status => :created, :location => @company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @company.destroy
        flash[:notice] = 'Company was successfully destroyed.'        
        format.html { redirect_to companies_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'Company could not be destroyed.'
        format.html { redirect_to @company }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @companies = Company.paginate(:page => params[:page], :per_page => COMPANIES_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @companies }
    end
  end

  def edit
  end

  def new
    @company = Company.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @company }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @company }
    end
  end

  def update
    respond_to do |format|
      if @company.update_attributes(params[:company])
        flash[:notice] = 'Company was successfully updated.'
        format.html { redirect_to @company }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_company
    @company = Company.find(params[:id]) if params[:id]
  end

end