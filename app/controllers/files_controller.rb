class FilesController < ApplicationController

  rescue_from Uploadcare::Exception::RequestError, with: :handle_error

  def index
    @files_data = Uploadcare::FileApi.get_files
    @files = @files_data[:results]
  end

  def store
    Uploadcare::FileApi.store_file(params[:id])
    flash[:success] = 'File has been successfully stored!'
    redirect_to_prev_location
  end

  def show
    @file = Uploadcare::FileApi.get_file(params[:id])
  end

  def destroy
    Uploadcare::FileApi.delete_file(params[:id])
    flash[:success] = 'File has been successfully deleted!'
    redirect_to_prev_location
  end

  private

  def redirect_to_prev_location
    redirect_to request.referer || files_path
  end

  def handle_error(e)
    flash[:alert] = e.message.presence || 'Something went wrong'
    redirect_to_prev_location
  end
end
