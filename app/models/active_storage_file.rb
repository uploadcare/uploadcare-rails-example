# frozen_string_literal: true

class ActiveStorageFile < ApplicationRecord
  validates :title, presence: true

  has_many_attached :files
end
