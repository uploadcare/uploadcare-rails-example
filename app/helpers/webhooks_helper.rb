# frozen_string_literal: true

module WebhooksHelper
  def webhook_events
    %w[file.uploaded file.info_updated file.deleted file.stored file.infected]
  end
end
