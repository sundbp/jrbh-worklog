ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboard'
  map.resource :user_session
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  map.resources :users
  map.resources :worklog_tasks
  map.resources :companies
  map.resources :work_periods

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
