# frozen_string_literal: true

class CommentsController < ApplicationController
  def index
    @comments = Comment.order("created_at DESC")
  end

  def new
    @comment = Comment.new
  end

  def edit
    find_comment
  end

  def show
    find_comment
    @attachments = Uploadcare::GroupApi.get_group(@comment.attachments.load.id)["files"] if @comment.attachments
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:success] = "Comment has been successfully created!"
      redirect_to comment_path(@comment)
    else
      flash.now[:alert] = @comment.errors.full_messages.join("; ")
      render :new
    end
  end

  def update
    find_comment
    if @comment.update(comment_params)
      flash[:success] = "Comment has been successfully updated!"
      redirect_to comment_path(@comment)
    else
      flash.now[:alert] = @comment.errors.full_messages.join("; ")
      render :edit
    end
  end

  def destroy
    find_comment
    @comment.destroy
    flash[:success] = "Comment has been successfully deleted!"
    redirect_to comments_path
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :image, :attachments)
  end

  def find_comment
    @comment = Comment.find(params[:id])
  end
end
