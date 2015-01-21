class CommentsController < ApplicationController

  def create
    params[:comment][:commentable_id] = Moped::BSON::ObjectId.
    from_string(
      params[:comment][:commentable_id]) if params[:comment]
    [:commentable_id].present?
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash[:notice] = "Comment saved"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to :back
  end

  def like
    @comment = Comment.find(params[:id])
    @comment.like!(current_user)
    redirect_to :back
  end

  def unlike
    @comment = Comment.find(params[:id])
    @comment.unlike!(current_user)
    redirect_to :back
  end

  def like_from_mail
    @comment = Comment.find(params[:id])
    if @comment.likes.include?(current_user.id)  
      flash[:notice] = "You have already liked the comment"
    else 
      @comment.like!(current_user)
      flash[:notice] = "You have liked the comment"
    end 
    redirect_to polymorphic_url([@comment.commentable.program, @comment.commentable.pitch, @comment.commentable])
  end
end
