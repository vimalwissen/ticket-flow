Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'pages#index'
   namespace :api do
    namespace :version1 do
      resources :tickets, param: :ticket_id  
      
      get 'dashboard/summary', to: 'dashboard#summary'
      get "dashboard/charts",  to: "dashboard#charts"
    end
  end
   get '*path', to: 'pages#index', via: :all

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Defines the root path route ("/")
  # root "posts#index"
end
