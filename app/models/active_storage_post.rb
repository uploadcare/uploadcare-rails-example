# frozen_string_literal: true

class ActiveStoragePost < ApplicationRecord
  validates :title, presence: true

  has_one_attached :cover_image
  has_many_attached :attachments
end
