class Discipline
  include Mongoid::Document
  include Mongoid::Slug

  has_many :events

  field :title, type: String
  slug :title

  validates_presence_of :title
end
