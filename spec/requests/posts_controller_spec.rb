# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :request do
  let(:post_object) { create :post }
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

  before do
    %i[get_group store_group].each do |stub_method|
      allow(Uploadcare::GroupApi).to receive(stub_method).and_return(results: file_group)
    end
    %i[store_file delete_file].each do |stub_method|
      allow(Uploadcare::FileApi).to receive(stub_method).and_return(results: file_group)
    end
  end

  describe 'GET index' do
    context 'when a response status is 200' do
      it 'returns a 200' do
        post_object
        get '/posts'
        expect(response.body).to match(post_object.title)
      end
    end
  end

  describe 'GET new' do
    it 'renders a template' do
      get '/posts/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'GET edit' do
    it 'renders a template' do
      get "/posts/#{post_object.id}/edit"
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    context 'when a response status is 200' do
      it 'returns a 200' do
        get "/posts/#{post_object.id}"
        expect(response).to render_template(:show)
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::GroupApi).to receive(:get_group).and_raise(Uploadcare::Exception::RequestError, '') }

      it 'returns an error' do
        get "/posts/#{post_object.id}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'POST create' do
    context 'when a post is created' do
      it 'creates a post' do
        expect do
          post '/posts', params: {
            post: { title: 'Title', logo: 'https://logourl.com', attachments: 'https://attachmentsurl.com' }
          }
        end.to change(Post, :count).by(1)
      end
    end

    context 'when a post has errors' do
      it 'returns post errors', :aggregate_failures do
        expect do
          post '/posts', params: {
            post: { title: '', logo: 'https://logourl.com', attachments: 'https://attachmentsurl.com' }
          }
        end.not_to change(Post, :count)
        expect(flash[:alert]).to match("Title can't be blank")
      end
    end
  end

  describe 'PATCH update' do
    context 'when a post is updated' do
      it 'updates a post' do
        expect do
          patch "/posts/#{post_object.id}", params: {
            post: {
              title: post_object.title.reverse,
              logo: "#{post_object.logo}/new",
              attachments: "#{post_object.attachments}/new"
            }
          }
        end.to(
          change { post_object.reload.title }.and(change { post_object.title })
                                             .and(change { post_object.attachments })
        )
      end
    end

    context 'when a post has errors' do
      it 'returns post errors', :aggregate_failures do
        old_attributes = post_object.attributes
        patch "/posts/#{post_object.id}", params: {
          post: { title: '', logo: "#{post_object.logo}/new", attachments: "#{post_object.attachments}/new" }
        }
        expect(post_object.reload.attributes).to eq(old_attributes)
        expect(flash[:alert]).to match("Title can't be blank")
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when a post is deleted' do
      it 'updates a post' do
        post_object
        expect { delete "/posts/#{post_object.id}" }.to change(Post, :count).by(-1)
      end
    end
  end
end
