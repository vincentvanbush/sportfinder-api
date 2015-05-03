module HasScore
  extend ActiveSupport::Concern

  included do
    field :score, type: Integer
  end
end
