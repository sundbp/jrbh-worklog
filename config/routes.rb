JrbhWorklog::Application.routes.draw do
  resources :roles

  resources :role_allocations
  resources :billing_infos
  resources :timeplans
  resource :user_session
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  resources :users
  resources :worklog_tasks
  resources :companies
  resources :work_periods
  match 'dashboard' => 'dashboard#index'
  root :to => 'dashboard#index'
  match '/:controller(/:action(/:id))'
end
