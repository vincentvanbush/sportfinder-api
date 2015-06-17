class CommentSerializer < ActiveModel::Serializer
  attributes :user_email, :content, :created_at, :timestamp

  def id() object.id.to_s end

  def user_email
    object.user.email
  end

  def timestamp
    object.created_at.to_i
  end
end
