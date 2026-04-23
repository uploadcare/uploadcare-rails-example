# frozen_string_literal: true

class WebhooksController < ApplicationController
  def index
    @webhooks = uploadcare_client.webhooks.list
  end

  def new; end

  def edit
    find_webhook
  end

  def show
    find_webhook
  end

  def create
    webhook = uploadcare_client.webhooks.create(**webhook_params)
    flash[:success] = "Webhook with id #{webhook.id} has been successfully created!"
    redirect_to webhook_path(webhook.id)
  end

  def update
    webhook_id = params[:id]&.to_i
    uploadcare_client.webhooks.update(id: webhook_id, **webhook_params)
    flash[:success] = "Webhook with id #{webhook_id} has been successfully updated!"
    redirect_to webhook_path(webhook_id)
  end

  def destroy
    target_url = params[:target_url]
    uploadcare_client.webhooks.delete(target_url: target_url)
    flash[:success] = "Webhook has been successfully deleted!"
    redirect_to webhooks_path
  end

  private

  def find_webhook
    webhook_id = params[:id]&.to_i
    @webhook = uploadcare_client.webhooks.list.detect { |wh| wh.id == webhook_id }
  end

  def webhook_params
    params
      .require(:webhook)
      .permit(:target_url, :is_active, :event)
      .merge(is_active: params.dig(:webhook, :is_active).present?)
      .to_h
      .symbolize_keys
  end
end
