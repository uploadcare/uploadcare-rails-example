# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.order("created_at DESC")
  end

  def new
    @post = Post.new
  end

  def edit
    find_post
  end

  def show
    find_post
    @attachments = Uploadcare::GroupApi.get_group(@post.attachments.load.id)["files"] if @post.attachments
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      flash[:success] = "Post has been successfully created!"
      redirect_to post_path(@post)
    else
      flash.now[:alert] = @post.errors.full_messages.join("; ")
      render :new
    end
  end

  def update
    find_post
    if @post.update(post_params)
      flash[:success] = "Post has been successfully updated!"
      redirect_to post_path(@post)
    else
      flash.now[:alert] = @post.errors.full_messages.join("; ")
      render :edit
    end
  end

  def destroy
    find_post
    @post.destroy
    flash[:success] = "Post has been successfully deleted!"
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :logo, :attachments)
  end

  def find_post
    @post = Post.find(params[:id])
  end
end
