# frozen_string_literal: true

class UploadcareCollection
  def self.normalize(data)
    return data if data.is_a?(Hash)

    results = data.respond_to?(:resources) ? data.resources : Array(data)
    {
      total: data.respond_to?(:total) ? data.total : results.size,
      results: results
    }
  end
end
