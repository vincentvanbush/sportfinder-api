class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event
  has_one :user

  field :content, type: String
end
