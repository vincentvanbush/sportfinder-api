module HasLapTimes
  extend ActiveSupport::Concern

  included do
    field :lap_times, type: Array
  end
end