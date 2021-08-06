# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController, type: :request do
  let(:webhook) do
    Uploadcare::Webhook.new(
      'id' => 816_965,
      'created' => '2021-08-05T11:04:15.563004Z',
      'updated' => '2021-08-05T11:04:15.563025Z',
      'event' => 'file.uploaded',
      'target_url' => 'https://newexample.com/listen/new/112222',
      'project' => 123_681,
      'is_active' => true
    )
  end

  describe 'GET index' do
    context 'when a response status is 200' do
      before { allow(Uploadcare::WebhookApi).to receive(:get_webhooks).and_return([]) }

      it 'returns a 200' do
        get '/webhooks'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::WebhookApi).to receive(:get_webhooks).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        get '/webhooks'
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'GET new' do
    it 'renders a template' do
      get '/webhooks/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'GET edit' do
    before { allow(Uploadcare::WebhookApi).to receive(:get_webhooks).and_return([webhook]) }

    it 'renders a template' do
      get "/webhooks/#{webhook.id}/edit"
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    context 'when a response status is 200' do
      before { allow(Uploadcare::WebhookApi).to receive(:get_webhooks).and_return([webhook]) }

      it 'returns a 200' do
        get "/webhooks/#{webhook.id}"
        expect(response).to render_template(:show)
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::WebhookApi).to receive(:get_webhooks).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        get "/webhooks/#{webhook.id}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'POST create' do
    let(:params) do
      { webhook: { target_url: 'https://example.com', event: 'file.uploaded', is_active: true } }
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::WebhookApi).to receive(:create_webhook).and_return(webhook) }

      it 'returns a 200' do
        post '/webhooks', params: params
        expect(flash[:success]).to match('has been successfully created!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::WebhookApi).to receive(:create_webhook).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        post '/webhooks', params: params
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'PATCH update' do
    let(:params) do
      { webhook: { target_url: 'https://newexample.com', event: 'file.uploaded', is_active: true } }
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::WebhookApi).to receive(:update_webhook).and_return(webhook) }

      it 'returns a 200' do
        patch "/webhooks/#{webhook.id}", params: params
        expect(flash[:success]).to match('has been successfully updated!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::WebhookApi).to receive(:update_webhook).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        patch "/webhooks/#{webhook.id}", params: params
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe 'DELETE delete' do
    let(:target_url) { 'https://example.com' }

    context 'when a response status is 200' do
      before { allow(Uploadcare::WebhookApi).to receive(:delete_webhook) }

      it 'returns a 200' do
        delete '/webhook', params: { target_url: webhook.target_url }
        expect(flash[:success]).to match('Webhook has been successfully deleted!')
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::WebhookApi).to receive(:delete_webhook).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        delete '/webhook', params: { target_url: webhook.target_url }
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end
end
