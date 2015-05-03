class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :discipline
  belongs_to :user
  embeds_many :messages
  embeds_many :contenders
  embeds_many :comments
  embeds_many :votes

  field :title, type: String
  field :description, type: String
  field :venue, type: String
  field :start_date, type: DateTime
  field :finished?, type: Boolean, default: false

  validates_presence_of :title
  validates :description, length: { maximum: 200 }
  validates_presence_of :venue
  validates_presence_of :start_date
  validates_date :start_date, on_or_after: :created_at
  validates_presence_of :finished?

  validates_presence_of :user
  validates_presence_of :discipline
end
