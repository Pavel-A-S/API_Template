class Item < ApplicationRecord
  has_many :lots
  has_many :advertisements, through: :lots
end
