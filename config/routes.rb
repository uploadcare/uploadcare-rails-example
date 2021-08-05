# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Files
  resources :files, only: %i[index show destroy]
  post '/store_file/:id', to: 'files#store', as: 'store_file'
  get '/new_store_file_batch', to: 'files#new_store_file_batch', as: 'new_store_file_batch'
  get '/new_delete_file_batch', to: 'files#new_delete_file_batch', as: 'new_delete_file_batch'
  post '/store_file_batch', to: 'files#store_file_batch', as: 'store_file_batch'
  delete '/delete_file_batch', to: 'files#delete_file_batch', as: 'delete_file_batch'

  # Uploads
  get '/upload_new_local_file', to: 'uploads#new_local', as: 'upload_new_local_file'
  get '/upload_new_file_from_url', to: 'uploads#new_from_url', as: 'upload_new_file_from_url'
  post '/upload_local_file', to: 'uploads#upload_local', as: 'upload_local_file'
  post '/upload_file_from_url', to: 'uploads#upload_from_url', as: 'upload_file_from_url'

  # File Groups
  resources :file_groups, only: %i[index new show create]
  post '/store_file_group/:id', to: 'file_groups#store', as: 'store_file_group'

  # Document Conversion
  resources :document_conversions, only: %i[new create]
  get '/document_conversion', to: 'document_conversions#show', as: 'document_conversion'

  root 'files#index'
end
