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
          patch :status, to: "tickets#change_status"   # PATCH /tickets/:ticket_id/status
          patch :assign, to: "tickets#assign"          # PATCH /tickets/:ticket_id/assign
        end
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
