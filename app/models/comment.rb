class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event
  belongs_to :user

  field :content, type: String
end
