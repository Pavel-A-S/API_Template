class Lot < ApplicationRecord
  LOT_FIELDS = %i[id item_id amount price status].freeze

  belongs_to :storage
  belongs_to :item
  has_one :advertisement, dependent: :destroy
  has_one :player, through: :storage

  validates_uniqueness_of(
    :item_id,
    scope: %i[storage_id status], message: 'already present on the market'
  )

  validate :market_capacity, if: -> { on_market? }

  validates(
    :amount, numericality: {
      only_integer: true, greater_than: 0, less_than: 11,
      message: '- has to be from 1 to 10'
    }, if: -> { on_market? }
  )

  enum status: { storage: 0, on_market: 1 }

  def market_capacity
    return unless player

    lots_limit = GAME_SETTINGS['market']['lots_limit']
    market_is_full = player.lots_on_market.count >= lots_limit
    return unless market_is_full && !player.lots_on_market.find_by(id: id)

    errors.add(:market, 'is full of lots')
  end

  def select_fields
    as_json(only: LOT_FIELDS, include: { item: { only: %i[id name] } })
  end

  def base_attributes(storage_id, status)
    { storage_id: storage_id, item_id: item.id, status: Lot.statuses[status] }
  end

  def full_attributes(storage_id, status, amount, price)
    base_attributes(storage_id, status).merge(amount: amount, price: price)
  end

  def send_to(location, amount, storage_id, price = 0)
    target_lot = Lot.find_by(base_attributes(storage_id, location))
    target_lot.price = price if target_lot && location == :on_market
    target_lot.amount += amount if target_lot
    target_lot ||= Lot.new(full_attributes(storage_id, location, amount, price))
    self.amount -= amount
    make_a_deal(target_lot)
  end

  def payment(target_lot)
    return unless target_lot.storage? && player.id != target_lot.player.id

    (player.currency_amount += price) && player.save!
    (target_lot.player.currency_amount -= price) && target_lot.player.save!
  end

  def make_a_deal(target_lot)
    transaction do
      self.amount.zero? ? destroy! : save!
      target_lot.save!
      payment(target_lot)
    end
    target_lot
  rescue ActiveRecord::RecordInvalid => e
    e
  end
end
