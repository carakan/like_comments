class CommentsController < ApplicationController
  def create
    commentable = find_commentable
    @comment = commentable.common_comments.new(params[:comment])
    @comment.user_id = current_user.id if current_user
    @comment.save!
    respond_to do |format|
      flash[:notice] = (@comment.type_common) ? 'Lo comentaste' : 'Te gusta esto'
      format.html { redirect_to request.referer }
    end
  rescue
    flash[:error] = "No se pudo añadir"
    respond_to do |format|
      format.html { redirect_to request.referer }
    end
  end

  def destroy
    @comment = Comment.first(:conditions => {:id => params[:id], :user_id => current_user.id})
    if @comment && @comment.destroy
      flash[:notice] = (@comment.type_common) ? 'Borraste tu comentario' : 'Ya no te gusta esto'
    else
      flash[:notice] = "No pudiste borrarlo"
    end
    respond_to do |format|
      format.html { redirect_to request.referer }
    end
  end

  private
  
  def deliver_new_comment_notification(comment, referer)
    if comment.commentable_owner_email && !comment.spam
      CommentMailer.deliver_new_comment_notification(comment, referer)
    end
  end

  def find_commentable
    if params[:commentable_type] && params[:commentable_id]
      return params[:commentable_type].classify.constantize.find(params[:commentable_id])
    else
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
    end
  end
end
