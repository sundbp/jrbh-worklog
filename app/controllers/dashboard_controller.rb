class DashboardController < ApplicationController
  def index
    if current_user then
      @user = current_user.login
    else
      redirect_to login_path  
    end
  end
end
