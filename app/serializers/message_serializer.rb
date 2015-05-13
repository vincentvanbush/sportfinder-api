class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :attachment_url, :created_at, :timestamp

  def id() object.id.to_s end

  def timestamp
    object.created_at.to_i
  end
end
