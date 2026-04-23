# frozen_string_literal: true

class Post < ApplicationRecord
  validates_presence_of :title

  has_uploadcare_file :logo
  has_uploadcare_files :attachments
end
