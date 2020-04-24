Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/spotify_auth/oauth_callback', to: 'spotify_auth#oauth_callback', as: 'spotify_oauth_callback'
end
