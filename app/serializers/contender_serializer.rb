class ContenderSerializer < ActiveModel::Serializer
  attributes :id, :title, :squad_members

  def id() object.id.to_s end
end
