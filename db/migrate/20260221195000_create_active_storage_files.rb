# frozen_string_literal: true

class CreateActiveStorageFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :active_storage_files do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end
end
