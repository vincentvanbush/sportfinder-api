class Vote
  include Mongoid::Document

  embedded_in :event
  has_one :user

  field :positive?, type: Boolean

  validates_presence_of :positive?
  validates_presence_of :user?
end
