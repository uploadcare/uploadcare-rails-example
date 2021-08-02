require "rails_helper"

RSpec.describe FilesController, type: :request do
  describe "GET index" do
    context 'when a response status is 200' do
      before { allow(Uploadcare::FileApi).to receive(:get_files).and_return(results: []) }

      it "returns a 200" do
        get '/files'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::FileApi).to receive(:get_files).and_raise(Uploadcare::Exception::RequestError, '') }

      it "returns an error" do
        get '/files'
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe "GET show" do
    let(:uuid) { SecureRandom.uuid }
    let(:file) do
      Uploadcare::File.new(
        "datetime_removed": nil,
        "datetime_stored": "2018-11-26T12:49:10.477888Z",
        "datetime_uploaded": "2018-11-26T12:49:09.945335Z",
        "image_info": {
          "color_mode": "RGB",
          "orientation": nil,
          "format": "JPEG",
          "sequence": false,
          "height": 500,
          "width": 500,
          "geo_location": nil,
          "datetime_original": nil,
          "dpi": [
            144,
            144
          ]
        },
        "is_image": true,
        "is_ready": true,
        "mime_type": "application/octet-stream",
        "original_file_url": "https://ucarecdn.com/3c269810-c17b-4e2c-92b6-25622464d866/papaya.jpg",
        "original_filename": "papaya.jpg",
        "size": 642,
        "url": "https://api.uploadcare.com/files/3c269810-c17b-4e2c-92b6-25622464d866/",
        "uuid": "3c269810-c17b-4e2c-92b6-25622464d866",
        "variations": nil,
        "video_info": nil,
        "source": nil,
        "rekognition_info": {
          "Art": 0.60401,
          "Home Decor": 0.719,
          "Ornament": 0.60401,
          "Shutter": 0.719,
          "Arabesque Pattern": 0.60401,
          "Window": 0.719,
          "Curtain": 0.719,
          "Brick": 0.75331,
          "Window Shade": 0.719,
          "Balcony": 0.70572
        }
      )
    end

    context 'when a response status is 200' do
      before { allow(Uploadcare::FileApi).to receive(:get_file).and_return(file) }

      it "returns a 200" do
        get "/files/#{uuid}"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::FileApi).to receive(:get_file).and_raise(Uploadcare::Exception::RequestError, '') }

      it "returns an error" do
        get "/files/#{uuid}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe "GET store" do
    let(:uuid) { SecureRandom.uuid }

    context 'when a response status is 200' do
      before { allow(Uploadcare::FileApi).to receive(:store_file) }

      it "returns a 200" do
        get "/store_file/#{uuid}"
        expect(flash[:success]).to match('File has been successfully stored!')
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::FileApi).to receive(:store_file).and_raise(Uploadcare::Exception::RequestError, '') }

      it "returns an error" do
        get "/store_file/#{uuid}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end

  describe "GET delete" do
    let(:uuid) { SecureRandom.uuid }

    context 'when a response status is 200' do
      before { allow(Uploadcare::FileApi).to receive(:delete_file) }

      it "returns a 200" do
        delete "/files/#{uuid}"
        expect(flash[:success]).to match('File has been successfully deleted!')
      end
    end

    context 'when a response status is 4xx' do
      before { allow(Uploadcare::FileApi).to receive(:delete_file).and_raise(Uploadcare::Exception::RequestError, '') }

      it "returns an error" do
        delete "/files/#{uuid}"
        expect(flash[:alert]).to match('Something went wrong')
      end
    end
  end
end
