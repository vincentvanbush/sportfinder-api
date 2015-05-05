class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event

  field :content, type: String
  field :attachment_url, type: String

  scope :after, ->(datetime) {
    where(:created_at.gt => datetime)
  }
end
