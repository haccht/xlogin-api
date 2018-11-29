Rails.application.routes.draw do
  get 'actions/create'
  root to: 'vendors#index'
  resources :vendors do
    resource :actions, only: :create, constraints: { format: 'json' }
  end
end
