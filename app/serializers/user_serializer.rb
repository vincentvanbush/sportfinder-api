class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :auth_token	

  def id
    object.id.to_s
  end

  has_many :events, serializer: UserEventSerializer
end
