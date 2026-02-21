# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveStorageFilesController, type: :request do
  let(:record) { create(:active_storage_file) }
  let(:upload_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.txt'), 'text/plain') }

  describe 'GET index' do
    it 'returns a 200' do
      record
      get '/active_storage_files'
      expect(response).to have_http_status(:ok)
    end

    it 'renders a unified page with upload form and listing header' do
      get '/active_storage_files'

      expect(response.body).to include('Using with Active Storage')
      expect(response.body).to include('Upload with Active Storage')
      expect(response.body).to include('No ActiveStorage uploads yet. Use the form above to create one.')
    end
  end

  describe 'GET new' do
    it 'redirects to index' do
      get '/active_storage_files/new'
      expect(response).to redirect_to(active_storage_files_path)
    end
  end

  describe 'GET show' do
    it 'returns a 200' do
      get "/active_storage_files/#{record.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'renders uploaded files section' do
      get "/active_storage_files/#{record.id}"

      expect(response.body).to include('Uploaded files')
      expect(response.body).to include('No files attached.')
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a record' do
        expect do
          post '/active_storage_files', params: {
            active_storage_file: {
              title: 'New set',
              description: 'desc',
              files: [ upload_file ]
            }
          }
        end.to change(ActiveStorageFile, :count).by(1)

        expect(ActiveStorageFile.last.files).to be_attached
      end
    end

    context 'with invalid params' do
      it 'does not create a record' do
        expect do
          post '/active_storage_files', params: {
            active_storage_file: {
              title: '',
              description: 'desc'
            }
          }
        end.not_to change(ActiveStorageFile, :count)
      end
    end
  end

  describe 'PATCH update' do
    it 'updates a record' do
      patch "/active_storage_files/#{record.id}", params: {
        active_storage_file: {
          title: 'Updated',
          description: 'updated desc',
          files: [ upload_file ]
        }
      }

      expect(record.reload.title).to eq('Updated')
      expect(record.files).to be_attached
    end
  end

  describe 'DELETE destroy' do
    it 'deletes a record' do
      record
      expect { delete "/active_storage_files/#{record.id}" }.to change(ActiveStorageFile, :count).by(-1)
    end
  end
end
