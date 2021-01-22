Rails.application.routes.draw do
  root to: 'drivers#index'
  get 'cmd',    to: 'commands#show'
  get 'stream', to: 'commands#stream'
  resources :drivers
end
