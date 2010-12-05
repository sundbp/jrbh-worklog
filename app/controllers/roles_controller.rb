class RolesController < ApplicationController
  before_filter :find_role
  before_filter :require_admin_user
  
  layout "admin_panel"
  
  ROLES_PER_PAGE = 20

  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to @role }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @role.destroy
        flash[:notice] = 'Role was successfully destroyed.'        
        format.html { redirect_to roles_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'Role could not be destroyed.'
        format.html { redirect_to @role }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @roles = Role.paginate(:page => params[:page], :per_page => ROLES_PER_PAGE, :order => 'name ASC')
    @num_roles = Role.all.count
    respond_to do |format|
      format.html
      format.xml  { render :xml => @roles }
    end
  end

  def edit
  end

  def new
    @role = Role.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @role }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @role }
    end
  end

  def update
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to @role }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_role
    @role = Role.find(params[:id]) if params[:id]
  end

end
