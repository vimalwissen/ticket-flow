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
      resources :tickets, param: :ticket_id
      get 'dashboard/summary', to: 'dashboard#summary'
    end
  end

  # ---- DEFAULT CATCH-ALL ----
  get '*path', to: proc { 
    [200, { 'Content-Type' => 'application/json' }, [{ message: 'API Running' }.to_json]] 
  }
end
