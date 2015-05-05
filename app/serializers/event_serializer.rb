class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :venue, :start_date, :finished?

  # belongs_to :discipline
  has_one :user, serializer: EventUserSerializer

  def id
    object.id.to_s
  end
end
