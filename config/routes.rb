Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :videos do
    collection do
      resource :sync, only: [:create]
    end

    resource :transcribe, only: [:create]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "videos#index"
end
