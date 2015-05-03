module HasStats
  extend ActiveSupport::Concern

  included do
    field :stats, type: Hash
  end
end
