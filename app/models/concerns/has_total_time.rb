module HasTotalTime
  extend ActiveSupport::Concern

  included do
    field :total_time, type: String
  end
end
