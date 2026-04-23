# frozen_string_literal: true

class ActiveStoragePostsController < ApplicationController
  def index
    @active_storage_posts = ActiveStoragePost
      .with_attached_cover_image
      .with_attached_attachments
      .order("created_at DESC")
  end

  def new
    @active_storage_post = ActiveStoragePost.new
  end

  def edit
    find_active_storage_post
  end

  def show
    find_active_storage_post
  end

  def create
    @active_storage_post = ActiveStoragePost.new(active_storage_post_params)
    if @active_storage_post.save
      flash[:success] = "Active Storage post has been successfully created!"
      redirect_to active_storage_post_path(@active_storage_post)
    else
      flash.now[:alert] = @active_storage_post.errors.full_messages.join("; ")
      render :new
    end
  end

  def update
    find_active_storage_post
    if @active_storage_post.update(active_storage_post_params)
      flash[:success] = "Active Storage post has been successfully updated!"
      redirect_to active_storage_post_path(@active_storage_post)
    else
      flash.now[:alert] = @active_storage_post.errors.full_messages.join("; ")
      render :edit
    end
  end

  def destroy
    find_active_storage_post
    @active_storage_post.destroy
    flash[:success] = "Active Storage post has been successfully deleted!"
    redirect_to active_storage_posts_path
  end

  private

  def active_storage_post_params
    params.require(:active_storage_post).permit(:title, :cover_image, attachments: [])
  end

  def find_active_storage_post
    @active_storage_post = ActiveStoragePost.find(params[:id])
  end
end
