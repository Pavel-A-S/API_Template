class Storage < ApplicationRecord
  STORAGE_FIELDS = %i[storage_id created_at updated_at].freeze

  has_one :player
  has_many :lots

  def select_fields
    as_json(
      only: %i[id],
      include: {
        lots: {
          except: STORAGE_FIELDS, include: { item: { only: %i[id name] } }
        }
      }
    )
  end
end
