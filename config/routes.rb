Jobscraper::Application.routes.draw do

  root 'jobs#index'
  match '/about', to: 'static_pages#about', via: 'get'

  resources :jobs

end
