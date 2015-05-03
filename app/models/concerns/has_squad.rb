module HasSquad
  extend ActiveSupport::Concern

  included do
    field :squad_members, type: Array
  end
end
