class Discipline
  include Mongoid::Document

  has_many :events

  field :title, type: String
end
