class Vote
  include Mongoid::Document

  belongs_to :event
  belongs_to :user

  field :positive?, type: Boolean

  validates_presence_of :event?
  validates_presence_of :positive?
  validates_presence_of :user?
end
