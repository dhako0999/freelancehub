Rails.application.routes.draw do
  
  resource :session
  resources :passwords, param: :token

  resource :account, only: %i[show edit update]                                                               

  get "sign_up",
      to: "registration#new",
      as: :new_registration

  post "sign_up",
      to: "registration#create",
      as: :registration    

  get "email_verification/resend",
      to: "email_verifications#new",
      as: :new_email_verification
  
  post "email_verification/resend",
       to: "email_verifications#create",
       as: :resend_email_verification
  
  get "email_verification/:token",
      to: "email_verifications#show",
      as: :email_verification


  root "dashboard#index"
  get "dashboard", to: "dashboard#index", as: :dashboard

  get "home", to: "pages#home"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"

  resources :clients do
    resources :projects do
      resources :tasks
    end
  end

  resources :attachments, only: :destroy
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get "assistant",
      to: "assistant#show",
      as: :assistant

  post "assistant",
      to: "assistant#create"

      resources :ai_conversations,
                path: "assistant/conversations",
                only: %i[index show create update destroy] do
          resources :ai_messages, only: :create do
            collection do
              post :stream
            end

            member do
              get :rendered
            end
          end
      end

end
