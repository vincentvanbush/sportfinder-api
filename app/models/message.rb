class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event

  field :content, type: String
end
