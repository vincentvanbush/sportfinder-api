class UserEventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :venue, :start_date, :finished?

  def id
    object.id.to_s
  end
end
