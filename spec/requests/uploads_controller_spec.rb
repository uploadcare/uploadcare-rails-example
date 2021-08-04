# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadsController, type: :request do
  describe 'GET new_local' do
    it 'renders a template' do
      get '/upload_new_local_file'
      expect(response).to render_template(:new_local)
    end
  end

  describe 'GET upload_new_file_from_url' do
    it 'renders a template' do
      get '/upload_new_file_from_url'
      expect(response).to render_template(:new_from_url)
    end
  end

  describe 'POST upload_local' do
    let(:file) do
      Rack::Test::UploadedFile.new('spec/fixtures/blank.txt', 'plain/text')
    end

    context 'when a response status is 200' do
      before do
        allow(Uploadcare::UploadApi).to receive(:upload_file).and_return(OpenStruct.new(original_filename: 'name'))
      end

      it 'returns a 200', :aggregate_failures do
        post '/upload_local_file',
             params: { file: { file: file, filename: 'filename', mime_type: 'mime_type', store: 'false' } }

        expect(flash[:success]).to match('has been successfully uploaded!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::UploadApi).to receive(:upload_file).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        post '/upload_local_file',
             params: { file: { file: file, filename: 'filename', mime_type: 'mime_type', store: 'false' } }

        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'POST upload_from_url' do
    let(:url) { 'https://ucarecdn.com/26fbb022-4d7a-4dde-9f86-49b29f8407f8/zzz' }

    context 'when a response status is 200' do
      before do
        allow(Uploadcare::UploadApi).to receive(:upload_file).and_return([OpenStruct.new(original_filename: 'name')])
      end

      it 'returns a 200', :aggregate_failures do
        post '/upload_file_from_url', params: { file: { url: url, filename: 'filename', store: 'false' } }

        expect(flash[:success]).to match('has been successfully uploaded!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::UploadApi).to receive(:upload_file).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        post '/upload_file_from_url', params: { file: { url: url, filename: 'filename', store: 'false' } }

        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end
end
