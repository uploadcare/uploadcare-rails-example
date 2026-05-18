# frozen_string_literal: true

class CreateActiveStoragePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :active_storage_posts do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
