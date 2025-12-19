Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

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
      resources :ticket_form_options, only: [ :index ]
      resources :tickets, param: :ticket_id do
        member do
          patch :assign, to: "tickets#assign"
          put :update, to: "tickets#update"
          post "comments", to: "comments#create"
          get  "comments", to: "comments#index"
          delete "comments/:id", to: "comments#destroy"
          post "attachment", to: "attachments#create"
          get "attachment", to: "attachments#show"
          get "attachment/download", to: "attachments#download"
          delete "attachment", to: "attachments#destroy"
        end
        collection do
          post   :watch,  to: "watchers#create"
          delete :watch, to: "watchers#destroy"
        end
      end
      resources :sla_policies, only: [ :index, :show, :create, :update, :destroy ]
      resources :notifications, only: [ :index ] do
        collection do
          patch :mark_read
          patch :mark_all_read
        end
      end

      get "dashboard/summary", to: "dashboard#summary"
      get "dashboard/charts",  to: "dashboard#charts"
      resources :workflows
      resources :ticket_automators, only: [:create, :update] do
        member do
          post :event, to: "ticket_automators#create_event"
          put  :node,  to: "ticket_automators#create_node"
          put  :publish, to: "ticket_automators#publish"
        end
      end
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
