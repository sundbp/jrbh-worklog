class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy]

  layout "dashboard"
  
  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user_session }
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      if @user_session.save
        flash[:notice] = 'Successfully loggin in.'
        format.html { redirect_to root_url }
        format.xml  { render :xml => @user_session, :status => :created, :location => @user_session }
      else
        flash[:error] = "Failed login attempt."
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    respond_to do |format|
      if @user_session.destroy
        flash[:notice] = 'Successfully logged out.'
        format.html { redirect_to root_url }
        format.xml  { head :ok }
      else
        flash[:error] = 'Failed to log out properly.'
        format.html { redirect_to root_url }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

end