class CommentSerializer < ActiveModel::Serializer
  attributes :content, :created_at

  def id() object.id.to_s end
end
