Rails.application.routes.draw do
  root "challenges#index"

  resources :challenges, only: %i[ index new create show ]

  get  "c/:token" => "joins#new", as: :join
  post "c/:token" => "joins#create"

  resources :checkins, only: %i[ create destroy ]

  resource :session, only: %i[ new create destroy ]
  resource :verification, only: %i[ new create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
