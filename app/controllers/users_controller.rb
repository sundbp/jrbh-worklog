class UsersController < ApplicationController
  before_filter :find_user
  before_filter :require_admin_user
  
  layout "admin_panel"
  
  USERS_PER_PAGE = 20

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to @user }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.destroy
        flash[:notice] = 'User was successfully destroyed.'        
        format.html { redirect_to users_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'User could not be destroyed.'
        format.html { redirect_to @user }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @users = User.paginate(:page => params[:page], :per_page => USERS_PER_PAGE, :order => 'alias ASC')
    @all_users = User.find(:all)
    @active_users = User.active_employees
    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
    end
  end

  def edit
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to @user }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_user
    @user = User.find(params[:id]) if params[:id]
  end

end