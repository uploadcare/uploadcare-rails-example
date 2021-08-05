# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversions::DocumentConversionsController, type: :request do
  let(:conversion_result_body) do
    {
      result: [
        {
          original_source: '982fe2fe-6eb1-4130-8963-29406f274c05/document/-/format/png/-/page/1/',
          token: 21_396_005,
          uuid: 'e62d7506-0d40-4029-b7a6-41327e1554f6'
        }
      ],
      problems: problems
    }
  end
  let(:problems) { {} }
  let(:conversion_result) { OpenStruct.new(success: conversion_result_body) }

  describe 'GET new' do
    before { allow(Uploadcare::FileApi).to receive(:get_files).and_return(results: []) }

    it 'renders a template' do
      get '/document_conversions/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'GET show' do
    let(:status_result) { OpenStruct.new(success: body) }
    let(:body) do
      {
        status: 'finished',
        error: nil,
        result: { uuid: 'e62d7506-0d40-4029-b7a6-41327e1554f6' }
      }
    end

    shared_examples 'renders the :show template' do
      before { allow(Uploadcare::ConversionApi).to receive(:get_document_conversion_status).and_return(status_result) }

      it 'renders a template' do
        get document_conversion_path(result: conversion_result.success)
        expect(response).to render_template(:show)
      end
    end

    it_behaves_like 'renders the :show template'

    it_behaves_like 'renders the :show template' do
      let(:problems) { ['problem'] }
    end
  end

  describe 'POST create' do
    let(:params) do
      { file: 'b232bc66-e8e9-4d94-a723-e72dc5264a0f', target_format: 'doc', throw_error: false, store: false }
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::ConversionApi).to receive(:convert_document).and_return(conversion_result) }

      it 'returns a 200' do
        post '/document_conversions', params: params
        expect(flash[:notice]).to match('File conversion has been successfully started!')
      end
    end

    context 'when a RequestError occurred' do
      before do
        allow(Uploadcare::ConversionApi).to receive(:convert_document).and_raise(Uploadcare::Exception::RequestError,
                                                                                 '')
      end

      it 'returns an error' do
        post '/document_conversions', params: params
        expect(flash[:alert]).to match('Something went wrong')
      end
    end

    context 'when a ConversionError occurred' do
      let(:problem) { '{:"982fe2fe-6eb1-4130-8963-29406f274c05/document/-/format/doc/"=>"CDN Path error."}' }
      before do
        allow(Uploadcare::ConversionApi).to receive(:convert_document)
          .and_raise(Uploadcare::Exception::ConversionError, problem)
      end

      context 'when the option "throw_error" is enabled' do
        it 'raises an error' do
          expect do
            post '/document_conversions', params: params.merge(throw_error: true)
          end.to raise_error(Uploadcare::Exception::ConversionError)
        end
      end

      context 'when the option "throw_error" is disabled' do
        it 'redirects to :show' do
          post '/document_conversions', params: params.except(:throw_error)
          expect(response).to redirect_to(document_conversion_path(problem: problem))
        end
      end
    end
  end
end
