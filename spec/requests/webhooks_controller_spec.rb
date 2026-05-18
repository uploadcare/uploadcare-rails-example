# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhooksController, type: :request do
  let(:webhooks_accessor) { double("UploadcareWebhooksAccessor") }
  let(:client) { double("UploadcareClient", webhooks: webhooks_accessor) }
  let(:webhook) do
    Uploadcare::Webhook.new(
      {
        "id" => 816_965,
        "created" => "2021-08-05T11:04:15.563004Z",
        "updated" => "2021-08-05T11:04:15.563025Z",
        "event" => "file.uploaded",
        "target_url" => "https://newexample.com/listen/new/112222",
        "project" => 123_681,
        "is_active" => true
      },
      Uploadcare.client
    )
  end

  before do
    stub_uploadcare_client(client)
  end

  describe "GET index" do
    it "returns a 200" do
      allow(webhooks_accessor).to receive(:list).and_return([])

      get "/webhooks"

      expect(response).to have_http_status(:ok)
    end

    it "returns an error on request failure" do
      allow(webhooks_accessor).to receive(:list).and_raise(Uploadcare::Exception::RequestError, "")

      get "/webhooks"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "GET new" do
    it "renders a template" do
      get "/webhooks/new"

      expect(response).to render_template(:new)
    end
  end

  describe "GET edit" do
    it "renders a template" do
      allow(webhooks_accessor).to receive(:list).and_return([ webhook ])

      get "/webhooks/#{webhook.id}/edit"

      expect(response).to render_template(:edit)
    end
  end

  describe "GET show" do
    it "returns a 200" do
      allow(webhooks_accessor).to receive(:list).and_return([ webhook ])

      get "/webhooks/#{webhook.id}"

      expect(response).to render_template(:show)
    end

    it "returns an error on request failure" do
      allow(webhooks_accessor).to receive(:list).and_raise(Uploadcare::Exception::RequestError, "")

      get "/webhooks/#{webhook.id}"

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "POST create" do
    let(:params) do
      { webhook: { target_url: "https://example.com", event: "file.uploaded", is_active: true } }
    end

    it "creates a webhook" do
      allow(webhooks_accessor).to receive(:create).and_return(webhook)

      post "/webhooks", params: params

      expect(flash[:success]).to match("has been successfully created!")
    end

    it "returns an error on request failure" do
      allow(webhooks_accessor).to receive(:create).and_raise(Uploadcare::Exception::RequestError, "")

      post "/webhooks", params: params

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "PATCH update" do
    let(:params) do
      { webhook: { target_url: "https://newexample.com", event: "file.uploaded", is_active: true } }
    end

    it "updates a webhook" do
      allow(webhooks_accessor).to receive(:update).and_return(webhook)

      patch "/webhooks/#{webhook.id}", params: params

      expect(flash[:success]).to match("has been successfully updated!")
    end

    it "returns an error on request failure" do
      allow(webhooks_accessor).to receive(:update).and_raise(Uploadcare::Exception::RequestError, "")

      patch "/webhooks/#{webhook.id}", params: params

      expect(flash[:alert]).to match("Something went wrong")
    end
  end

  describe "DELETE destroy" do
    it "deletes a webhook" do
      allow(webhooks_accessor).to receive(:delete)

      delete "/webhook", params: { target_url: webhook.target_url }

      expect(flash[:success]).to match("Webhook has been successfully deleted!")
    end

    it "returns an error on request failure" do
      allow(webhooks_accessor).to receive(:delete).and_raise(Uploadcare::Exception::RequestError, "")

      delete "/webhook", params: { target_url: webhook.target_url }

      expect(flash[:alert]).to match("Something went wrong")
    end
  end
end
