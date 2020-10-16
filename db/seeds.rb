# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

STATUSES = {
  storage: Lot.statuses[:storage], on_market: Lot.statuses[:on_market]
}.freeze

GAME_ATTRIBUTES = [
  {
    player_attributes: { nickname: 'player1', currency_amount: 100 },
    items: [
      {
        name: 'item1_1', amount: 100, price: 101, status: STATUSES[:on_market]
      },
      { name: 'item1_2', amount: 100, price: 102, status: STATUSES[:storage] },
      { name: 'item1_3', amount: 100, price: 103, status: STATUSES[:on_market] }
    ]
  },
  {
    player_attributes: { nickname: 'player2', currency_amount: 200 },
    items: [
      {
        name: 'item2_1', amount: 200, price: 201, status: STATUSES[:on_market]
      },
      { name: 'item2_2', amount: 200, price: 202, status: STATUSES[:storage] },
      { name: 'item2_3', amount: 200, price: 203, status: STATUSES[:on_market] }
    ]
  },
  {
    player_attributes: { nickname: 'player3', currency_amount: 300 },
    items: [
      {
        name: 'item3_1', amount: 300, price: 301, status: STATUSES[:on_market]
      },
      { name: 'item3_2', amount: 300, price: 302, status: STATUSES[:storage] },
      { name: 'item3_3', amount: 300, price: 303, status: STATUSES[:on_market] }
    ]
  }
].freeze

GAME_ATTRIBUTES.each do |a|
  Player.find_or_create_by(nickname: a[:player_attributes][:nickname]) do |p|
    p.assign_attributes(a[:player_attributes])
    storage = p.create_storage
    a[:items].each do |i|
      lot = Lot.create(
        storage_id: storage.id,
        item_id: Item.create(name: i[:name]).id,
        amount: i[:amount],
        status: i[:status],
        price: i[:price]
      )
      next unless i[:status] == Lot.statuses[:on_market]

      Advertisement.create(
        lot_id: lot.id, body: "#{i[:name]} - this is absolutely unique item"
      )
    end
  end
end
