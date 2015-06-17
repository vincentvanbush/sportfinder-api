module HasTennisScores
  extend ActiveSupport::Concern

  included do
    field :tennis_scores, type: Hash
	end
end
