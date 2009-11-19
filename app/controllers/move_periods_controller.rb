class MovePeriodsController < ApplicationController
  before_filter :require_admin_user

  layout "admin_panel"

  def index
  end

  def move_periods
    wlt_from_id = params['worklog_task_from']
    wlt_to_id = params['worklog_task_to']
    success = true
    unless wlt_from_id.nil? or wlt_to_id.nil? or (wlt_from_id == wlt_to_id)
      wlt_from = WorklogTask.find(wlt_from_id)
      wlt_to = WorklogTask.find(wlt_to_id)
      wlt_from.work_periods.each do |wp|
        wp.worklog_task_id = wlt_to.id
        s = wp.save
        success = s if success == true
      end
    end
    respond_to do |format|
      if success
        flash[:notice] = 'Worklog periods were successfully moved.'
        format.html { redirect_to :conteroller => "move_periods", :action => :index }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Could not move periods between worklog tasks properly, please investigate!'
        format.html { render :action => :index }
        format.xml  { render :xml => "failed move", :status => :unprocessable_entity }
      end
    end
  end

end
