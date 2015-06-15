class Contender
  include Mongoid::Document

  include HasSquad
  include HasTotalTime
  include HasScore
  include HasPartialScores
  include HasStats
  include HasLapTimes

  embedded_in :event

  field :title, type: String
end
