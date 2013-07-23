Atomic::Application.routes.draw do
  root to: "rooms#index"
  resources :rooms do
    resources :messages
  end
  resources :messages
end
