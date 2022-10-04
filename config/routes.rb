# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Files
  resources :files, only: %i[index show destroy]
  post '/store_file/:id', to: 'files#store', as: 'store_file'
  post '/copy_file/:id', to: 'files#copy', as: 'copy_file'
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
  resources :file_groups, only: %i[index new show create destroy]
  post '/store_file_group/:id', to: 'file_groups#store', as: 'store_file_group'

  scope module: 'conversions', shallow: true do
    # Document Conversion
    resources :document_conversions, only: %i[new create]
    get '/document_conversion', to: 'document_conversions#show', as: 'document_conversion'

    # Video Conversion
    resources :video_conversions, only: %i[new create]
    get '/video_conversion', to: 'video_conversions#show', as: 'video_conversion'
  end

  # Projects
  get '/project', to: 'projects#show', as: 'project'

  # Webhooks
  resources :webhooks, except: %i[destroy]
  delete '/webhook', to: 'webhooks#destroy', as: 'delete_webhook'

  # Posts
  resources :posts

  # FileMetadata
  resources :file_metadata, only: :index do
    collection do
      get :all_metadata_show
      get :metadata_show
      patch :metadata_update
      delete :metadata_delete
    end
  end

  # Add-Ons:
  resources :virus_scan, only: %i[new create index] do
    collection do
      get :check_status
      get :show_status
    end
  end

  resources :rekognition_labels, only: %i[new create index] do
    collection do
      get :check_status
      get :show_status
    end
  end

  resources :remove_bg, only: %i[new create index] do
    collection do
      get :check_status
      get :show_status
    end
  end

  root 'projects#show'
end
# rubocop:enable Metrics/BlockLength
