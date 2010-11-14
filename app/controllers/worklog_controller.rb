class WorklogController < ApplicationController
  before_filter :require_user

  layout "worklog-edit"

  helper_method :available_users, :available_users_exists?
  helper_method :available_worklog_tasks, :available_worklog_tasks_exists?

  def edit
    if params.has_key? "id"
      @worklog = Worklog.new(params["id"])
    else
      @worklog = Worklog.new(current_user.alias)
    end
    render :action => "edit"
  end

  private

  def available_users
    return User.all.collect {|c| [ c.alias, c.id ] }
  end

  def available_users_exists?
    return !available_users.blank?
  end

  def available_worklog_tasks
    return WorklogTask.all.collect {|c| [ c.name, c.id ] }
  end

  def available_worklog_tasks_exists?
    return !available_worklog_tasks.blank?
  end
end
