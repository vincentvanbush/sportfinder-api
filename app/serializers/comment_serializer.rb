class CommentSerializer < ActiveModel::Serializer
  attributes :user_email, :content, :created_at

  def id() object.id.to_s end

  def user_email
    object.user.email
  end
end
