class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true

  after_save :increase_counter

  after_destroy :decrement_counter
  
  # NOTE: Comments belong to a user
  belongs_to :user
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  protected
  
  def increase_counter
    if self.type_common
      self.commentable.class.increment_counter(:comments_count, self.commentable.id)
    else
      self.commentable.class.increment_counter(:likes_count, self.commentable.id)
    end
  end

  def decrement_counter
    if self.type_common
      self.commentable.class.decrement_counter(:comments_count, self.commentable.id)
    else
      self.commentable.class.decrement_counter(:likes_count, self.commentable.id)
    end
  end
end