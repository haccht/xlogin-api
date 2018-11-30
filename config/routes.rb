Rails.application.routes.draw do
  get 'actions/create'
  root to: 'vendors#index'
  resources :vendors, param: :name do
    resource :actions, only: :create, constraints: { format: 'json' }
  end
end
