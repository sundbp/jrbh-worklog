JrbhWorklog::Application.routes.draw do
  get "reports/utilization_summary"
  get "reports/individual_summary"
  get "reports/company_summary"
  resources :billing_rates
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
