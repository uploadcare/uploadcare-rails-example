# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileGroupsController, type: :request do
  let(:file_group) do
    Uploadcare::Group.new(
      {
        'id' => 'd476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20',
        'datetime_created' => '2021-07-16T11:03:01.182939Z',
        'datetime_stored' => '2021-07-30T10:26:47.294442Z',
        'files_count' => 20,
        'cdn_url' => 'https://ucarecdn.com/d476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20/',
        'url' => 'https://api.uploadcare.com/groups/d476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20/',
        'files' => [{
          'size' => 21_813,
          'total' => 21_813,
          'done' => 21_813,
          'uuid' => '3ae6a420-9de3-4088-9fad-301de9932251',
          'file_id' => '3ae6a420-9de3-4088-9fad-301de9932251',
          'original_filename' => 'thumbnail_0.jpg',
          'is_image' => true,
          'is_stored' => false,
          'image_info' => {
            'width' => 600, 'height' => 400, 'format' => 'JPEG', 'color_mode' => 'RGB', 'geo_location' => nil,
            'orientation' => nil, 'dpi' => nil, 'datetime_original' => nil, 'sequence' => false
          },
          'video_info' => nil,
          'is_ready' => true,
          'filename' => 'thumbnail_0.jpg',
          'mime_type' => 'image/jpeg',
          'default_effects' => ''
        }]
      }
    )
  end

  describe 'GET new' do
    it 'renders a template' do
      get '/file_groups/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'GET index' do
    context 'when a response status is 200' do
      before { allow(Uploadcare::GroupApi).to receive(:get_groups).and_return(results: []) }

      it 'returns a 200' do
        get '/file_groups'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::GroupApi).to receive(:get_groups).and_raise(Uploadcare::Exception::RequestError, '') }

      it 'returns an error' do
        get '/file_groups'
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'GET show' do
    let(:id) { 'd476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20' }

    context 'when a response status is 200' do
      before { allow(Uploadcare::GroupApi).to receive(:get_group).and_return(file_group) }

      it 'returns a 200' do
        get "/file_groups/#{id}"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::GroupApi).to receive(:get_group).and_raise(Uploadcare::Exception::RequestError, '') }

      it 'returns an error' do
        get "/file_groups/#{id}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'POST store' do
    let(:id) { 'd476f4c9-44a9-4670-88a5-c3cf5d26b6c2~20' }

    context 'when a response status is 200' do
      before { allow(Uploadcare::GroupApi).to receive(:store_group) }

      it 'returns a 200' do
        post "/store_file_group/#{id}"
        expect(flash[:success]).to match('File group has been successfully stored!')
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::GroupApi).to receive(:store_group).and_raise(Uploadcare::Exception::RequestError, '') }

      it 'returns an error' do
        post "/store_file_group/#{id}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'POST create' do
    context 'when a response status is 200' do
      before { allow(Uploadcare::GroupApi).to receive(:create_group).and_return(file_group) }

      it 'returns a 200' do
        post '/file_groups', params: { files: { file: '3ae6a420-9de3-4088-9fad-301de9932251' } }
        expect(flash[:success]).to match('File group has been successfully created!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::GroupApi).to receive(:create_group).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        post '/file_groups', params: { files: { file: '3ae6a420-9de3-4088-9fad-301de9932251' } }
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end
end
