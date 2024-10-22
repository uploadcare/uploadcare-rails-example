# frozen_string_literal: true

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :image, type: String
  field :attachments, type: String

  mount_uploadcare_file :image
  mount_uploadcare_file_group :attachments
end
