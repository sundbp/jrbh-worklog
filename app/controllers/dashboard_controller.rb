class DashboardController < ApplicationController
  before_filter :require_user

  layout "dashboard"

  def index
    # nothing for us to do, it's all taken care of by filters etc
  end
end
