Rails.application.routes.draw do
  # ---- AUTH ROUTES ----
  scope :auth do
    post :login,   to: "auth#login"
    post :logout,  to: "auth#logout"
    post :refresh, to: "auth#refresh"
  end

  # ---- TICKET API ROUTES ----
  namespace :api do
    namespace :version1 do
      resources :users
      resources :tickets, param: :ticket_id do
        member do
          patch :status, to: "tickets#change_status"   
          patch :assign, to: "tickets#assign"       
          post "watchers", to: "watchers#create"
          delete "watchers/:watcher_id", to: "watchers#destroy"  
          get "watchers", to: "watchers#index" 
          post "comments", to: "comments#create"
          get  "comments", to: "comments#index"
          delete "comments/:id", to: "comments#destroy"
        end
      end
      resources :notifications, only: [:index] do
        member { patch :mark_read }
        collection { patch :mark_all_read }
      end

      get 'dashboard/summary', to: 'dashboard#summary'
      get 'dashboard/charts',  to: 'dashboard#charts'
    end
  end

  

  # ---- CORS PRE-FLIGHT (OPTIONS) ----
  match '*path', to: 'application#options_request', via: :options

  # ---- DEFAULT CATCH-ALL FOR OTHER GET REQUESTS ----
  get '*path', to: proc {
    [
      200,
      { 'Content-Type' => 'application/json' },
      [{ message: 'API Running' }.to_json]
    ]
  }
end
