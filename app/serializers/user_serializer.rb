class UserSerializer < ActiveModel::Serializer
  attributes :id, :email

  def id
    object.id.to_s
  end

  has_many :events, serializer: UserEventSerializer
end
