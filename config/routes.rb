Rails.application.routes.draw do
  namespace :api do
    namespace :version1 do
      resources :tickets, param: :ticket_id
      get 'dashboard/summary', to: 'dashboard#summary'
      get "dashboard/charts",  to: "dashboard#charts"
    end
  end

  # Default: return a simple JSON response when hitting unmatched routes
  get '*path', to: proc { [200, { 'Content-Type' => 'application/json' }, [{ message: 'API Running' }.to_json]] }
end
