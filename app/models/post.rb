# frozen_string_literal: true

class Post < ApplicationRecord
  validates_presence_of :title

  mount_uploadcare_file :logo
  mount_uploadcare_file_group :attachments
end
