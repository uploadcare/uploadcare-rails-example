# frozen_string_literal: true

class ActiveStorageFilesController < ApplicationController
  before_action :set_active_storage_file, only: %i[show edit update destroy]

  def index
    @active_storage_file = ActiveStorageFile.new
    @active_storage_files = ActiveStorageFile.includes(files_attachments: :blob).order(created_at: :desc)
  end

  def show; end

  def new
    redirect_to active_storage_files_path
  end

  def edit; end

  def create
    @active_storage_file = ActiveStorageFile.new(active_storage_file_params)
    if @active_storage_file.save
      flash[:success] = "ActiveStorage file set has been successfully created!"
      redirect_to active_storage_file_path(@active_storage_file)
    else
      flash.now[:alert] = @active_storage_file.errors.full_messages.join("; ")
      @active_storage_files = ActiveStorageFile.includes(files_attachments: :blob).order(created_at: :desc)
      render :index
    end
  end

  def update
    if @active_storage_file.update(active_storage_file_params)
      flash[:success] = "ActiveStorage file set has been successfully updated!"
      redirect_to active_storage_file_path(@active_storage_file)
    else
      flash.now[:alert] = @active_storage_file.errors.full_messages.join("; ")
      render :edit
    end
  end

  def destroy
    @active_storage_file.destroy
    flash[:success] = "ActiveStorage file set has been successfully deleted!"
    redirect_to active_storage_files_path
  end

  private

  def active_storage_file_params
    params.require(:active_storage_file).permit(:title, :description, files: [])
  end

  def set_active_storage_file
    @active_storage_file = ActiveStorageFile.find(params[:id])
  end
end
