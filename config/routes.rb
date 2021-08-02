# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :files, only: %i[index show destroy]
  get '/store_file/:id', to: 'files#store', as: 'store_file'

  root 'files#index'
end
