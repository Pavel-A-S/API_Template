class Lot < ApplicationRecord
  LOT_FIELDS = %i[id item_id amount price status].freeze

  belongs_to :storage
  belongs_to :item
  has_one :advertisement, dependent: :destroy

  validates_uniqueness_of(
    :item_id,
    scope: %i[storage_id status], message: 'already present on the market'
  )

  enum status: { storage: 0, on_market: 1 }

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
    make_a_deal(target_lot, amount)
  end

  def make_a_deal(target_lot, amount)
    self.amount -= amount
    transaction do
      self.amount.zero? ? destroy! : save!
      target_lot.save!
    end
    target_lot
  rescue ActiveRecord::RecordInvalid => e
    e
  end
end
