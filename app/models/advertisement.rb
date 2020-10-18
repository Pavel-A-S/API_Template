class Advertisement < ApplicationRecord
  LOT_FIELDS = %i[id item_id amount price status].freeze

  belongs_to :lot
  has_one :item, through: :lot
  has_one :player, through: :lot

  scope(
    :with_filter, lambda do |parameters|
      condition = {}
      condition1 = parameters.slice(:amount, :price)
      condition2 = parameters.slice(:name)
      condition = condition.merge(lots: condition1) unless condition1.empty?
      condition = condition.merge(items: condition2) unless condition2.empty?
      where(condition).prepare_result
    end
  )

  scope :prepare_result, -> { Advertisement.new.select_fields(self) }

  def select_fields(data = self)
    data.as_json(
      only: %i[id body],
      include: { lot: { only: LOT_FIELDS }, item: { only: %i[name id] } }
    )
  end

  def publish
    player.currency_amount -= GAME_SETTINGS['advertisement']['charge']
    transaction { player.save! && save! }
    self
  rescue ActiveRecord::RecordInvalid => e
    e
  end
end
