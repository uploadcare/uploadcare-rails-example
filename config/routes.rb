# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Files
  resources :files, only: %i[index show destroy]
  get '/store_file/:id', to: 'files#store', as: 'store_file'
  get '/new_store_file_batch', to: 'files#new_store_file_batch', as: 'new_store_file_batch'
  get '/new_delete_file_batch', to: 'files#new_delete_file_batch', as: 'new_delete_file_batch'
  post '/store_file_batch', to: 'files#store_file_batch', as: 'store_file_batch'
  delete '/delete_file_batch', to: 'files#delete_file_batch', as: 'delete_file_batch'

  root 'files#index'
end
