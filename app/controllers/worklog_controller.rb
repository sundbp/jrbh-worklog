class WorklogController < ApplicationController
  before_filter :require_user

  layout "worklog"

  def edit
    render :action => "edit", :layout => "worklog-edit"
  end

end
