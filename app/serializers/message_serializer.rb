class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :attachment_url, :created_at

  def id() object.id.to_s end
end
