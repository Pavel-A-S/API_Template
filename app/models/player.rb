class Player < ApplicationRecord
  PLAYER_FIELDS = %i[id nickname currency_amount storage_id].freeze

  belongs_to :storage
  has_many :lots, through: :storage
  has_many :advertisements, through: :lots

  has_many(
    :lots_on_market, -> { where(status: Lot.statuses[:on_market]) },
    source: :lots, through: :storage
  )

  validates(
    :currency_amount, numericality: {
      only_integer: true, greater_than_or_equal_to: 0,
      message: '- not enough money'
    }
  )

  def select_fields
    as_json(only: PLAYER_FIELDS)
  end
end
