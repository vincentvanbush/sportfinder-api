class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :venue, :start_date, :finished?,
             :positive_votes, :negative_votes

  # belongs_to :discipline
  has_one :user, serializer: EventUserSerializer
  has_many :contenders
  has_many :comments

  def id
    object.id.to_s
  end

  def positive_votes
    object.positive_votes
  end

  def negative_votes
    object.negative_votes
  end
end
