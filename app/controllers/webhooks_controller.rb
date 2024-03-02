# frozen_string_literal: true

class WebhooksController < ApplicationController
  def index
    @webhooks = Uploadcare::WebhookApi.get_webhooks
  end

  def new; end

  def edit
    find_webhook
  end

  def show
    find_webhook
  end

  def create
    webhook = Uploadcare::WebhookApi.create_webhook(webhook_params)
    flash[:success] = "Webhook with id #{webhook.id} has been successfully created!"
    redirect_to webhook_path(webhook.id)
  end

  def update
    webhook_id = params[:id]&.to_i
    Uploadcare::WebhookApi.update_webhook(webhook_id, webhook_params)
    flash[:success] = "Webhook with id #{webhook_id} has been successfully updated!"
    redirect_to webhook_path(webhook_id)
  end

  def destroy
    target_url = params[:target_url]
    Uploadcare::WebhookApi.delete_webhook(target_url)
    flash[:success] = "Webhook has been successfully deleted!"
    redirect_to webhooks_path
  end

  private

  def find_webhook
    webhook_id = params[:id]&.to_i
    @webhook = Uploadcare::WebhookApi.get_webhooks.detect { |wh| wh.id == webhook_id }
  end

  def webhook_params
    params
      .require(:webhook)
      .permit(:target_url, :is_active)
      .merge(event: "file.uploaded", is_active: params.dig(:webhook, :is_active).present?)
      .to_h
      .symbolize_keys
  end
end
