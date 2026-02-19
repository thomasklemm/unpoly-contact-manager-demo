Rails.application.routes.draw do
  root "contacts#index"

  resources :activities, only: [ :index, :new, :create, :show, :edit, :update, :destroy ]

  resources :contacts do
    member do
      patch :star
      patch :archive
    end
    resources :activities, only: [ :index, :create ]
  end

  resources :companies, only: [ :index, :new, :create, :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
