Rails.application.routes.draw do
  root to: 'pools#index'
  get 'cmd',    to: 'commands#show'
  get 'stream', to: 'commands#stream'
  resources :pools
end
