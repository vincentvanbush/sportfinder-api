module HasPartialScores
  extend ActiveSupport::Concern

  included do
    field :partial_scores, type: Hash
	end
end
