# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversions::VideoConversionsController, type: :request do
  let(:original_source) do
    '10878f4e-f02e-4f26-8b23-6f0395fa812f/video/-/size/600x400/change_ratio/' \
    '-/quality/best/-/format/ogg/-/cut/0:0:0.0/0:0:1.0/-/thumbs~2/1/'
  end
  let(:conversion_result_body) do
    {
      result: [
        {
          original_source: original_source,
          token: '21396005',
          uuid: 'e62d7506-0d40-4029-b7a6-41327e1554f6',
          thumbnails_group_uuid: '3cb7a928-9fa9-4d78-8db2-751eac3367e4~2'
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
      get '/video_conversions/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'GET show' do
    let(:status_result) { OpenStruct.new(success: body) }
    let(:body) do
      {
        status: 'finished',
        error: nil,
        result: { uuid: 'e62d7506-0d40-4029-b7a6-41327e1554f6',
                  thumbnails_group_uuid: '3cb7a928-9fa9-4d78-8db2-751eac3367e4~2' }
      }
    end

    shared_examples 'renders the :show template' do
      before { allow(Uploadcare::ConversionApi).to receive(:get_video_conversion_status).and_return(status_result) }

      it 'renders a template' do
        get video_conversion_path(result: conversion_result.success)
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
      {
        file: 'b232bc66-e8e9-4d94-a723-e72dc5264a0f',
        target_format: 'doc',
        size: { resize_mode: 'change_ratio', width: '200', height: '400' },
        cut: { start_time: '0:0:0.1', length: 'end' },
        thumbs: { n: 1, number: 2 },
        throw_error: false,
        store: false
      }
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::ConversionApi).to receive(:convert_video).and_return(conversion_result) }

      it 'returns a 200' do
        post '/video_conversions', params: params
        expect(flash[:notice]).to match('File conversion has been successfully started!')
      end
    end

    context 'when a RequestError occurred' do
      before do
        allow(Uploadcare::ConversionApi).to receive(:convert_video).and_raise(Uploadcare::Exception::RequestError,
                                                                              '')
      end

      it 'returns an error' do
        post '/video_conversions', params: params
        expect(flash[:alert]).to match('Something went wrong')
      end
    end

    context 'when a ConversionError occurred' do
      let(:problem) do
        '{:"982fe2fe-6eb1-4130-8963-29406f274c05/video/-/size/200x/change_ratio/\"=>\"Conversion service error.\"}'
      end
      before do
        allow(Uploadcare::ConversionApi).to receive(:convert_video)
          .and_raise(Uploadcare::Exception::ConversionError, problem)
      end

      context 'when the option "throw_error" is enabled' do
        it 'raises an error' do
          expect do
            post '/video_conversions', params: params.merge(throw_error: true)
          end.to raise_error(Uploadcare::Exception::ConversionError)
        end
      end

      context 'when the option "throw_error" is disabled' do
        it 'redirects to :show' do
          post '/video_conversions', params: params.except(:throw_error)
          expect(response).to redirect_to(video_conversion_path(problem: problem))
        end
      end
    end
  end
end
