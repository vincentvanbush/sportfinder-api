class UserEventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :venue, :start_date, :finished?,
             :discipline_id

  def id() object.id.to_s end
  def discipline_id() object.discipline_id.to_s end
end
