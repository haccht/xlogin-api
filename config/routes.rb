Rails.application.routes.draw do
  root to: 'drivers#index'
  get  'cmd', to: 'commands#show'
  post 'cmd', to: 'commands#show'
  resources :drivers
end
