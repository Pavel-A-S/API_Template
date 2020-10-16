class Player < ApplicationRecord
  PLAYER_FIELDS = %i[id nickname currency_amount storage_id].freeze

  belongs_to :storage

  def select_fields
    as_json(only: PLAYER_FIELDS)
  end
end
