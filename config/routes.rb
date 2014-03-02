Jobscraper::Application.routes.draw do

  devise_for :users
  root 'jobs#index'
  match '/about', to: 'static_pages#about', via: 'get'

  resources :jobs

end
