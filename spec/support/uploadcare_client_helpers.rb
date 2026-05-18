module UploadcareClientHelpers
  def stub_uploadcare_client(client)
    allow(Uploadcare::Rails).to receive(:client).and_return(client)
  end

  def uploadcare_paginated(*resources, total: resources.size)
    Uploadcare::Collections::Paginated.new(resources: resources, total: total, per_page: resources.size)
  end
end

RSpec.configure do |config|
  config.include UploadcareClientHelpers
end
