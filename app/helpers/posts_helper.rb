# frozen_string_literal: true

module PostsHelper
  def short_title(post, length = 30)
    "#{post.title.first(length)}#{post.title.length > length ? '...' : ''}"
  end
end
