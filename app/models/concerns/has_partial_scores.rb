module HasPartialScores
  extend ActiveSupport::Concern

  included do
    field :partial_scores, type: Array
  end
end
