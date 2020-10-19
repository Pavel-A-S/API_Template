RSpec.describe Lot, type: :model do
  fixtures :Lots, :Players, :Storages, :Items

  before(:each) do
    @correct_attributes = {
      item_id: 4,
      storage_id: 1,
      amount: 5,
      price: 100,
      status: Lot.statuses[:on_market]
    }

    @wrong_attributes = {
      item_id: 4,
      storage_id: 1,
      amount: 15,
      price: 100,
      status: Lot.statuses[:on_market]
    }
  end

  it 'Must not be errors if attributes are correct' do
    @lot = Lot.create(@correct_attributes)
    expect(@lot.errors.size).to eq(0)
  end

  it 'Must be error about amount of items' do
    @lot = Lot.create(@wrong_attributes)
    expect(@lot.errors.size).to eq(1)
    expect(@lot.errors.first).to eq([:amount, '- has to be from 1 to 10'])
  end
end
