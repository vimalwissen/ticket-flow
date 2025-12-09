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
      resources :ticket_form_options, only: [:index]
      resources :tickets, param: :ticket_id do
        member do
          patch :assign, to: "tickets#assign"
          put :update, to: "tickets#update"
          post   :watch, to: "watchers#create"
          delete :watch, to: "watchers#destroy"
          post "comments", to: "comments#create"
          get  "comments", to: "comments#index"
          delete "comments/:id", to: "comments#destroy"
          post "attachment", to: "attachments#create"
          get "attachment", to: "attachments#show"
          delete "attachment", to: "attachments#destroy"
        end
      end
      resources :notifications, only: [ :index ] do
        member { patch :mark_read }
        collection { patch :mark_all_read }
      end

      get "dashboard/summary", to: "dashboard#summary"
      get "dashboard/charts",  to: "dashboard#charts"
    end
  end



  # ---- CORS PRE-FLIGHT (OPTIONS) ----
  match "*path", to: "application#options_request", via: :options

  # ---- DEFAULT CATCH-ALL FOR OTHER GET REQUESTS ----
  get "*path", to: proc {
    [
      200,
      { "Content-Type" => "application/json" },
      [ { message: "API Running" }.to_json ]
    ]
  }
end
