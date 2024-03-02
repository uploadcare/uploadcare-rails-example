# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :request do
  describe 'GET show' do
    let(:uuid) { SecureRandom.uuid }
    let(:project) do
      Uploadcare::Project.new(
        "collaborators": [ { name: 'Mike', email: 'mike@mail.com' } ],
        "name": 'Hello, World!',
        "pub_key": 'demopublickey',
        "autostore_enabled": true
      )
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::ProjectApi).to receive(:get_project).and_return(project) }

      it 'returns a 200' do
        get '/project'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before do
        allow(Uploadcare::ProjectApi).to receive(:get_project).and_raise(Uploadcare::Exception::RequestError, '')
      end

      it 'returns an error' do
        get '/project'
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end
end
