# frozen_string_literal: true

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :image, type: String
  field :attachments, type: String

  validates :content, presence: true

  has_uploadcare_file :image
  has_uploadcare_files :attachments
end
