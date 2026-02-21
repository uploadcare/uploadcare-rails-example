# frozen_string_literal: true

class EnsureActiveStorageServiceNameColumn < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:active_storage_blobs)

    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string
      execute "UPDATE active_storage_blobs SET service_name = 'uploadcare' WHERE service_name IS NULL"
      change_column_null :active_storage_blobs, :service_name, false
    end
  end

  def down
    return unless table_exists?(:active_storage_blobs)
    return unless column_exists?(:active_storage_blobs, :service_name)

    remove_column :active_storage_blobs, :service_name
  end
end
